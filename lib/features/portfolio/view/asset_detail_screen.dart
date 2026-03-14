import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../controller/portfolio_controller.dart';
import '../model/asset_detail.dart';
import '../model/asset_reasoning.dart';
import '../service/asset_detail_service.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.ticker});
  final String ticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final detailAsync = ref.watch(assetDetailProvider(ticker));
    final investAmount = ref.watch(investmentAmountProvider);
    final currency = ref.watch(currencyProvider);

    final asset = portfolioAsync.asData?.value?.reasoning
        .cast<AssetReasoning?>()
        .firstWhere((a) => a?.ticker == ticker, orElse: () => null);

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ticker)),
        body: Center(
          child: Text('Asset not found in portfolio.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, color: colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 56.w, top: 32.h, right: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          asset.assetName,
                          style: GoogleFonts.manrope(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              asset.ticker,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            ),
                            if (detailAsync.asData?.value != null) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text(
                                  detailAsync.asData!.value.assetClass,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text(
                                  detailAsync.asData!.value.sector,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // ── Allocation + Amount ──────────────────
                  AnimatedListItem(
                    index: 0,
                    child: _AllocationCard(
                      asset: asset,
                      investAmount: investAmount,
                      currency: currency,
                      colorScheme: colorScheme,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ── Stats row ────────────────────────────
                  AnimatedListItem(
                    index: 1,
                    child: Row(
                      children: [
                        _StatTile(
                          label: 'Exp. Return',
                          value:
                              '${asset.expectedReturn >= 0 ? '+' : ''}${asset.expectedReturn.toStringAsFixed(1)}%',
                          colorScheme: colorScheme,
                        ),
                        SizedBox(width: 12.w),
                        _StatTile(
                          label: 'Volatility',
                          value: '${asset.volatility.toStringAsFixed(1)}%',
                          colorScheme: colorScheme,
                        ),
                        SizedBox(width: 12.w),
                        _StatTile(
                          label: 'Suitability',
                          value:
                              '${(asset.suitabilityScore * 100).toStringAsFixed(0)}%',
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ── Price history chart ──────────────────
                  AnimatedListItem(
                    index: 2,
                    child: detailAsync.when(
                      loading: () => _LoadingCard(
                          label: 'Loading price history...', colorScheme: colorScheme),
                      error: (e, _) => _ErrorCard(
                          label: 'Could not load market data', colorScheme: colorScheme),
                      data: (detail) => detail.priceHistory.length >= 2
                          ? _PriceHistoryChart(
                              prices: detail.priceHistory, colorScheme: colorScheme)
                          : _EmptyCard(
                              label: 'No price history available',
                              colorScheme: colorScheme),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Live market stats ────────────────────
                  AnimatedListItem(
                    index: 3,
                    child: detailAsync.when(
                      loading: () => _LoadingCard(
                          label: 'Loading market stats...', colorScheme: colorScheme),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (detail) =>
                          _MarketStatsSection(detail: detail, colorScheme: colorScheme),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── Suitability gauge ────────────────────
                  AnimatedListItem(
                    index: 4,
                    child: _SuitabilityGauge(
                      score: asset.suitabilityScore,
                      colorScheme: colorScheme,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ── Full explanation ─────────────────────
                  AnimatedListItem(
                    index: 5,
                    child: _SectionHeading(
                        text: 'Why this asset?', colorScheme: colorScheme),
                  ),
                  SizedBox(height: 12.h),
                  AnimatedListItem(
                    index: 6,
                    child: Text(
                      asset.explanation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.65,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ── About this asset ─────────────────────
                  AnimatedListItem(
                    index: 7,
                    child: detailAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (detail) {
                        if (detail.liveStats.description == null) {
                          return const SizedBox.shrink();
                        }
                        return _AboutSection(
                            description: detail.liveStats.description!,
                            colorScheme: colorScheme);
                      },
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Private widgets
// ──────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, required this.colorScheme});
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

// ── Allocation + Amount card ──────────────────────────────────

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({
    required this.asset,
    required this.investAmount,
    required this.currency,
    required this.colorScheme,
  });
  final AssetReasoning asset;
  final double? investAmount;
  final AppCurrency currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final allocAmount = investAmount != null
        ? investAmount! * asset.allocationPct / 100
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Allocation',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant)),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${asset.allocationPct.toStringAsFixed(1)}%',
                style: GoogleFonts.manrope(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              if (allocAmount != null) ...[
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Text(
                    formatAmount(allocAmount, currency),
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (allocAmount != null) ...[
            SizedBox(height: 6.h),
            Text(
              'of ${formatAmount(investAmount!, currency)} total investment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (investAmount == null) ...[
            SizedBox(height: 6.h),
            Text(
              'Enter an investment amount on the Portfolio tab to see the dollar breakdown.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Price History Chart ───────────────────────────────────────

class _PriceHistoryChart extends StatefulWidget {
  const _PriceHistoryChart({required this.prices, required this.colorScheme});
  final List<PricePoint> prices;
  final ColorScheme colorScheme;

  @override
  State<_PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<_PriceHistoryChart> {
  _ChartRange _range = _ChartRange.oneYear;

  List<PricePoint> get _filtered {
    final cutoff = DateTime.now().subtract(_range.duration);
    return widget.prices.where((p) => p.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final pts = _filtered;
    if (pts.length < 2) {
      return _EmptyCard(label: 'Not enough data for this range', colorScheme: cs);
    }

    final firstPrice = pts.first.close;
    final lastPrice = pts.last.close;
    final change = lastPrice - firstPrice;
    final changePct = firstPrice != 0 ? (change / firstPrice) * 100 : 0;
    final isPositive = change >= 0;

    final minY = pts.map((p) => p.close).reduce(math.min);
    final maxY = pts.map((p) => p.close).reduce(math.max);
    final yPadding = (maxY - minY) * 0.08;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price History',
                  style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
              Text(
                '${isPositive ? '+' : ''}${changePct.toStringAsFixed(1)}%',
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '\$${lastPrice.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isPositive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                size: 20.w,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Chart
          SizedBox(
            height: 180.h,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) {
                      return spots.map((s) {
                        return LineTooltipItem(
                          '\$${s.y.toStringAsFixed(2)}',
                          GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: minY - yPadding,
                maxY: maxY + yPadding,
                lineBarsData: [
                  LineChartBarData(
                    spots: pts.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.close);
                    }).toList(),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isPositive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Range selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _ChartRange.values.map((r) {
              final selected = r == _range;
              return GestureDetector(
                onTap: () => setState(() => _range = r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    r.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

enum _ChartRange {
  oneMonth('1M', Duration(days: 30)),
  threeMonths('3M', Duration(days: 90)),
  sixMonths('6M', Duration(days: 180)),
  oneYear('1Y', Duration(days: 365)),
  all('All', Duration(days: 365 * 10));

  final String label;
  final Duration duration;
  const _ChartRange(this.label, this.duration);
}

// ── Market Stats Section ──────────────────────────────────────

class _MarketStatsSection extends StatelessWidget {
  const _MarketStatsSection({required this.detail, required this.colorScheme});
  final AssetDetail detail;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final s = detail.liveStats;
    final f = detail.forecast;

    final stats = <_MarketStatRow>[
      if (s.currentPrice != null)
        _MarketStatRow(
          label: 'Current Price',
          value: '\$${_fmt(s.currentPrice!)}',
          explanation:
              'The most recent trading price for ${detail.ticker}.',
        ),
      if (s.previousClose != null)
        _MarketStatRow(
          label: 'Previous Close',
          value: '\$${_fmt(s.previousClose!)}',
          explanation:
              'The final price at the end of the last trading session.',
        ),
      if (s.marketCap != null)
        _MarketStatRow(
          label: 'Market Cap',
          value: _fmtLarge(s.marketCap!),
          explanation:
              'Total market value of all outstanding shares. Larger market caps usually '
              'mean lower risk and less price volatility.',
        ),
      if (s.peRatio != null)
        _MarketStatRow(
          label: 'P/E Ratio',
          value: s.peRatio!.toStringAsFixed(1),
          explanation:
              'Price-to-Earnings ratio \u2014 how much investors pay per dollar of '
              'earnings. A high P/E may signal high growth expectations; a low P/E '
              'may indicate undervaluation or lower growth.',
        ),
      if (s.dividendYield != null && s.dividendYield! > 0)
        _MarketStatRow(
          label: 'Dividend Yield',
          value: '${(s.dividendYield! * 100).toStringAsFixed(2)}%',
          explanation:
              'Annual dividend as a percentage of the stock price. A higher yield '
              'means more income, but extremely high yields can signal financial distress.',
        ),
      if (s.fiftyTwoWeekHigh != null)
        _MarketStatRow(
          label: '52-Week High',
          value: '\$${_fmt(s.fiftyTwoWeekHigh!)}',
          explanation:
              'The highest price this asset has traded at in the past year.',
        ),
      if (s.fiftyTwoWeekLow != null)
        _MarketStatRow(
          label: '52-Week Low',
          value: '\$${_fmt(s.fiftyTwoWeekLow!)}',
          explanation:
              'The lowest price this asset has traded at in the past year.',
        ),
      if (s.beta != null)
        _MarketStatRow(
          label: 'Beta',
          value: s.beta!.toStringAsFixed(2),
          explanation:
              'Measures how much the stock moves relative to the overall market. '
              'A beta > 1 means it\u0027s more volatile than the market; < 1 means less volatile.',
        ),
      if (s.avgVolume != null)
        _MarketStatRow(
          label: 'Avg. Volume',
          value: _fmtLarge(s.avgVolume!),
          explanation:
              'Average number of shares traded per day over the last 10 days. '
              'Higher volume means the asset is easier to buy and sell.',
        ),
      if (f != null) ...[
        _MarketStatRow(
          label: 'Forecast Return',
          value: '${f.expectedReturn >= 0 ? '+' : ''}${f.expectedReturn.toStringAsFixed(1)}%',
          explanation:
              'Our Prophet model\u0027s predicted return for this asset over the next 12 months. '
              'Based on historical price trends and seasonality.',
        ),
        _MarketStatRow(
          label: 'Forecast Volatility',
          value: '${f.volatility.toStringAsFixed(1)}%',
          explanation:
              'Expected price uncertainty. Higher volatility means the actual '
              'return could differ significantly from the forecast.',
        ),
      ],
    ];

    if (stats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Market Stats',
            style: GoogleFonts.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface)),
        SizedBox(height: 4.h),
        Text('Tap any stat for an explanation',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp, color: colorScheme.onSurfaceVariant)),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: stats.asMap().entries.map((entry) {
              final i = entry.key;
              final stat = entry.value;
              return _StatRowWidget(
                stat: stat,
                colorScheme: colorScheme,
                isLast: i == stats.length - 1,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000) {
      return v.toStringAsFixed(2);
    }
    if (v >= 1) {
      return v.toStringAsFixed(2);
    }
    return v.toStringAsFixed(4);
  }

  String _fmtLarge(double v) {
    if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _MarketStatRow {
  final String label;
  final String value;
  final String explanation;
  const _MarketStatRow(
      {required this.label, required this.value, required this.explanation});
}

class _StatRowWidget extends StatefulWidget {
  const _StatRowWidget({
    required this.stat,
    required this.colorScheme,
    required this.isLast,
  });
  final _MarketStatRow stat;
  final ColorScheme colorScheme;
  final bool isLast;

  @override
  State<_StatRowWidget> createState() => _StatRowWidgetState();
}

class _StatRowWidgetState extends State<_StatRowWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.stat.label,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp, color: cs.onSurfaceVariant)),
                    SizedBox(width: 6.w),
                    Icon(
                      _expanded
                          ? Icons.info_rounded
                          : Icons.info_outline_rounded,
                      size: 14.w,
                      color: cs.primary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                Text(widget.stat.value,
                    style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.stat.explanation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (!widget.isLast)
            Divider(height: 1, indent: 20.w, endIndent: 20.w,
                color: cs.outlineVariant.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

// ── Suitability Gauge ─────────────────────────────────────────

class _SuitabilityGauge extends StatelessWidget {
  const _SuitabilityGauge({required this.score, required this.colorScheme});
  final double score;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Suitability Score',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface)),
              Text('$pct%',
                  style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary)),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: score.clamp(0, 1),
              minHeight: 10.h,
              backgroundColor: colorScheme.surfaceContainerHigh,
              color: colorScheme.primaryContainer,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            _suitabilityExplanation(score),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _suitabilityExplanation(double s) {
    if (s >= 0.8) {
      return 'Excellent match. This asset closely aligns with your risk profile and investment goals.';
    } else if (s >= 0.6) {
      return 'Good fit. This asset is suitable for your profile with moderate alignment to your risk preferences.';
    } else if (s >= 0.4) {
      return 'Moderate fit. Included primarily for diversification benefits despite not being a perfect match.';
    }
    return 'Lower match. A small allocation provides portfolio balance, but this asset is outside your ideal risk zone.';
  }
}

// ── About Section ─────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.description, required this.colorScheme});
  final String description;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About',
            style: GoogleFonts.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface)),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.card,
          ),
          child: Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared small helpers ──────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.colorScheme,
  });
  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant)),
            SizedBox(height: 6.h),
            Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.label, required this.colorScheme});
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: colorScheme.primary),
          ),
          SizedBox(height: 12.h),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.label, required this.colorScheme});
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: colorScheme.error, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp, color: colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label, required this.colorScheme});
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
    );
  }
}
