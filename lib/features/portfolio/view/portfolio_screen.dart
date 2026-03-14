import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../controller/portfolio_controller.dart';
import '../model/asset_reasoning.dart';
import '../model/portfolio.dart';

const _chartColors = <Color>[
  Color(0xFF0066FF),
  Color(0xFF0D9488),
  Color(0xFFF59E0B),
  Color(0xFFF97316),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFFEF4444),
  Color(0xFF6366F1),
  Color(0xFF84CC16),
  Color(0xFFD946EF),
  Color(0xFF14B8A6),
  Color(0xFFF43F5E),
  Color(0xFF3B82F6),
  Color(0xFFA855F7),
  Color(0xFFEAB308),
  Color(0xFF22D3EE),
];

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final riskAsync = ref.watch(riskControllerProvider);
    final investAmount = ref.watch(investmentAmountProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: SafeArea(
        child: portfolioAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Text('Error: $e',
                  style: GoogleFonts.plusJakartaSans(
                      color: colorScheme.error)),
            ),
          ),
          data: (portfolio) {
            if (portfolio == null) {
              return Center(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pie_chart_outline_rounded,
                          size: 64.w, color: colorScheme.onSurfaceVariant),
                      SizedBox(height: 16.h),
                      Text(
                        'No portfolio yet',
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Generate one from the Home tab.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(portfolioControllerProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    AnimatedListItem(
                      index: 0,
                      child: Text(
                        'Your Portfolio',
                        style: GoogleFonts.manrope(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Investment amount input ─────────────────
                    AnimatedListItem(
                      index: 1,
                      child: _InvestmentInput(
                        currency: currency,
                        colorScheme: colorScheme,
                        onChanged: (v) =>
                            ref.read(investmentAmountProvider.notifier).set(v),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Risk summary card ────────────────────
                    AnimatedListItem(
                      index: 2,
                      child: _RiskSummaryCard(
                        portfolio: portfolio,
                        riskScore: riskAsync.asData?.value?.riskScore,
                        colorScheme: colorScheme,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Donut chart ──────────────────────────
                    AnimatedListItem(
                      index: 3,
                      child: _AllocationChart(
                        portfolio: portfolio,
                        investAmount: investAmount,
                        currency: currency,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Per-asset cards ──────────────────────
                    AnimatedListItem(
                      index: 4,
                      child: Text(
                        'Asset Breakdown',
                        style: GoogleFonts.manrope(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    ...portfolio.reasoning.asMap().entries.map((entry) {
                      final i = entry.key;
                      final asset = entry.value;
                      return AnimatedListItem(
                        index: i + 5,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _AssetCard(
                            asset: asset,
                            investAmount: investAmount,
                            currency: currency,
                            colorScheme: colorScheme,
                            onTap: () => context.push(
                                AppRoutes.assetDetailPath(asset.ticker)),
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Investment Amount Input ──────────────────────────────────

class _InvestmentInput extends StatefulWidget {
  const _InvestmentInput({
    required this.currency,
    required this.colorScheme,
    required this.onChanged,
  });
  final AppCurrency currency;
  final ColorScheme colorScheme;
  final ValueChanged<double?> onChanged;

  @override
  State<_InvestmentInput> createState() => _InvestmentInputState();
}

class _InvestmentInputState extends State<_InvestmentInput> {
  final _ctrl = TextEditingController();
  static final _commaFormatter = _ThousandSeparatorFormatter();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double? _parse() {
    final raw = _ctrl.text.replaceAll(',', '').trim();
    final v = double.tryParse(raw);
    return (v != null && v > 0) ? v : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: widget.colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visualize your investment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: widget.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Enter a total amount to see how it would be allocated across your assets',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: widget.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              _commaFormatter,
            ],
            decoration: InputDecoration(
              hintText: 'e.g. 10,000',
              prefixText: '${widget.currency.symbol} ',
              prefixStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: widget.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.check_circle_rounded,
                    color: widget.colorScheme.primary, size: 22.w),
                onPressed: () {
                  widget.onChanged(_parse());
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            onSubmitted: (_) => widget.onChanged(_parse()),
          ),
        ],
      ),
    );
  }
}

/// Inserts thousand-separator commas as the user types (e.g. 1000000 → 1,000,000).
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',', '');
    if (text.isEmpty) return newValue;

    final dotIndex = text.indexOf('.');
    final intPart = dotIndex == -1 ? text : text.substring(0, dotIndex);
    final decPart = dotIndex == -1 ? '' : text.substring(dotIndex);

    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    buf.write(decPart);

    final formatted = buf.toString();
    final cursorOffset = _adjustedCursor(newValue.text, formatted, newValue.selection.baseOffset);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  int _adjustedCursor(String raw, String formatted, int rawCursor) {
    var digits = 0;
    for (var i = 0; i < rawCursor && i < raw.length; i++) {
      if (raw[i] != ',') digits++;
    }
    var pos = 0;
    var count = 0;
    while (pos < formatted.length && count < digits) {
      if (formatted[pos] != ',') count++;
      pos++;
    }
    return pos;
  }
}

// ── Risk Summary ────────────────────────────────────────────

class _RiskSummaryCard extends StatelessWidget {
  const _RiskSummaryCard({
    required this.portfolio,
    required this.riskScore,
    required this.colorScheme,
  });
  final Portfolio portfolio;
  final double? riskScore;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
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
          if (riskScore != null) ...[
            RiskBadge(band: riskScore!),
            SizedBox(height: 16.h),
          ],
          Text(
            portfolio.riskSummary,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.08),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              'Expected annual return: +${portfolio.expectedReturn1y.toStringAsFixed(1)}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donut Chart ─────────────────────────────────────────────

class _AllocationChart extends StatelessWidget {
  const _AllocationChart({
    required this.portfolio,
    this.investAmount,
    required this.currency,
  });
  final Portfolio portfolio;
  final double? investAmount;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = portfolio.assetAllocation.entries.toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200.w,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 50.w,
                sections: List.generate(entries.length, (i) {
                  final e = entries[i];
                  return PieChartSectionData(
                    value: e.value * 100,
                    color: _chartColors[i % _chartColors.length],
                    radius: 40.w,
                    title: '',
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: List.generate(entries.length, (i) {
              final e = entries[i];
              final pct = (e.value * 100).toStringAsFixed(0);
              final amountLabel = investAmount != null
                  ? ' \u2022 ${formatAmount(e.value * investAmount!, currency)}'
                  : '';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _chartColors[i % _chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      '${e.key} $pct%$amountLabel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Asset Card ──────────────────────────────────────────────

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.colorScheme,
    required this.onTap,
    required this.currency,
    this.investAmount,
  });
  final AssetReasoning asset;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final AppCurrency currency;
  final double? investAmount;

  @override
  Widget build(BuildContext context) {
    final allocAmount = investAmount != null
        ? formatAmount(investAmount! * asset.allocationPct / 100, currency)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.assetName,
                          style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface)),
                      SizedBox(height: 2.h),
                      Text(asset.ticker,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer
                            .withValues(alpha: 0.12),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        '${asset.allocationPct.toStringAsFixed(1)}%',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    if (allocAmount != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        allocAmount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text('Suitability',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant)),
                SizedBox(width: 8.w),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.pill,
                    child: LinearProgressIndicator(
                      value: asset.suitabilityScore.clamp(0, 1),
                      minHeight: 6.h,
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      color: colorScheme.primaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${(asset.suitabilityScore * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              asset.explanation,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
