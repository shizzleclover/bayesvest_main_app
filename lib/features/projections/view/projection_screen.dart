import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';

class ProjectionScreen extends ConsumerStatefulWidget {
  const ProjectionScreen({super.key});

  @override
  ConsumerState<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends ConsumerState<ProjectionScreen> {
  final _initialCtrl = TextEditingController(text: '10,000');
  final _monthlyCtrl = TextEditingController(text: '500');
  double _years = 10;

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSimulation());
  }

  @override
  void dispose() {
    _initialCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  Future<void> _runSimulation() async {
    final pv = _parse(_initialCtrl);
    final pmt = _parse(_monthlyCtrl);
    final years = _years.round();

    if (pv <= 0) {
      setState(() => _error = 'Enter an initial investment amount');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.post(ApiEndpoints.portfolioSimulate, data: {
        'initial_investment': pv,
        'monthly_contribution': pmt,
        'years': years,
      });
      setState(() {
        _result = resp.data as Map<String, dynamic>;
        _loading = false;
      });
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['error']?.toString() ?? 'Simulation failed'
          : 'Simulation failed';
      setState(() {
        _error = msg;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Simulation')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            AnimatedListItem(
              index: 0,
              child: Text(
                'See exactly how your personalized portfolio could grow over time',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Inputs with explanations ───────────────────
            AnimatedListItem(
              index: 1,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledInput(
                      label: 'Initial investment',
                      hint: 'The lump sum you want to start with',
                      controller: _initialCtrl,
                      currency: currency,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    _LabeledInput(
                      label: 'Monthly contribution',
                      hint:
                          'How much you plan to add every month \u2014 even small amounts compound over time',
                      controller: _monthlyCtrl,
                      currency: currency,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time horizon',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: colorScheme.onSurfaceVariant)),
                        Text('${_years.round()} years',
                            style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary)),
                      ],
                    ),
                    Slider(
                      value: _years,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (v) => setState(() => _years = v),
                    ),
                    Text(
                      'How many years you plan to stay invested. Longer horizons typically mean higher returns.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _runSimulation,
                        icon: _loading
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.play_arrow_rounded),
                        label: Text(_loading ? 'Simulating...' : 'Run Simulation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            if (_error != null)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(_error!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp, color: colorScheme.error)),
                ),
              ),

            if (_result != null) ...[
              // ── Result highlight ──────────────────────────
              _buildResultHighlight(colorScheme, currency),
              SizedBox(height: 28.h),
              _buildChart(colorScheme, currency),
              SizedBox(height: 28.h),
              _buildBreakdown(colorScheme, currency),
              SizedBox(height: 28.h),
              _buildAssetProjections(colorScheme, currency),
              SizedBox(height: 40.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultHighlight(ColorScheme cs, AppCurrency currency) {
    final agg = _result!['aggregate'] as Map<String, dynamic>;
    final expected = (agg['expected'] as List).last;
    final portfolioReturn = _result!['portfolio_expected_return'] ?? 0;
    final years = _result!['years'] ?? 0;

    return AnimatedListItem(
      index: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.06),
              cs.tertiary.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: AppRadius.card,
        ),
        child: Column(
          children: [
            Text('Projected value in $years years',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp, color: cs.onSurfaceVariant)),
            SizedBox(height: 8.h),
            Text(
              formatAmount((expected as num).toDouble(), currency),
              style: GoogleFonts.manrope(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.primary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Based on your portfolio\u2019s $portfolioReturn% expected annual return',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ColorScheme cs, AppCurrency currency) {
    final agg = _result!['aggregate'] as Map<String, dynamic>;
    final opt = (agg['optimistic'] as List).cast<num>().map((e) => e.toDouble()).toList();
    final exp = (agg['expected'] as List).cast<num>().map((e) => e.toDouble()).toList();
    final pes = (agg['pessimistic'] as List).cast<num>().map((e) => e.toDouble()).toList();

    return AnimatedListItem(
      index: 3,
      child: Container(
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
              children: [
                _LegendDot(color: const Color(0xFF10B981)),
                SizedBox(width: 6.w),
                Text('Optimistic',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp, color: cs.onSurfaceVariant)),
                SizedBox(width: 16.w),
                _LegendDot(color: cs.primary),
                SizedBox(width: 6.w),
                Text('Expected',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp, color: cs.onSurfaceVariant)),
                SizedBox(width: 16.w),
                _LegendDot(color: const Color(0xFFF59E0B)),
                SizedBox(width: 6.w),
                Text('Pessimistic',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp, color: cs.onSurfaceVariant)),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 220.h,
              child: _ProjectionChart(
                optimistic: opt,
                expected: exp,
                pessimistic: pes,
                colorScheme: cs,
                currency: currency,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'The shaded area shows the range of possible outcomes. '
              'Optimistic assumes higher returns, pessimistic assumes lower.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: cs.onSurfaceVariant,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdown(ColorScheme cs, AppCurrency currency) {
    final agg = _result!['aggregate'] as Map<String, dynamic>;
    final opt = (agg['optimistic'] as List).last as num;
    final exp = (agg['expected'] as List).last as num;
    final pes = (agg['pessimistic'] as List).last as num;
    final total = (_result!['total_contributed'] as num).toDouble();
    final years = _result!['years'] ?? 0;

    return AnimatedListItem(
      index: 4,
      child: Container(
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
            Text('After $years years',
                style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            SizedBox(height: 16.h),
            _Row(
                label: 'You contribute',
                value: formatAmount(total, currency),
                colorScheme: cs),
            _Row(
                label: 'Optimistic scenario',
                value: formatAmount(opt.toDouble(), currency),
                colorScheme: cs,
                valueColor: const Color(0xFF10B981)),
            _Row(
                label: 'Expected scenario',
                value: formatAmount(exp.toDouble(), currency),
                colorScheme: cs,
                valueColor: cs.primary),
            _Row(
                label: 'Pessimistic scenario',
                value: formatAmount(pes.toDouble(), currency),
                colorScheme: cs,
                valueColor: const Color(0xFFF59E0B)),
            SizedBox(height: 8.h),
            _Row(
              label: 'Expected profit',
              value: formatAmount(exp.toDouble() - total, currency),
              colorScheme: cs,
              valueColor: exp.toDouble() - total >= 0
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetProjections(ColorScheme cs, AppCurrency currency) {
    final assets = (_result!['asset_projections'] as List?) ?? [];
    if (assets.isEmpty) return const SizedBox.shrink();

    return AnimatedListItem(
      index: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Per-Asset Breakdown',
              style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          SizedBox(height: 6.h),
          Text(
            'How each asset in your portfolio is projected to perform individually',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp, color: cs.onSurfaceVariant),
          ),
          SizedBox(height: 16.h),
          ...assets.map<Widget>((a) {
            final asset = a as Map<String, dynamic>;
            final contributed = (asset['total_contributed'] as num).toDouble();
            final expectedFinal = (asset['expected_final'] as num).toDouble();
            final profit = (asset['expected_profit'] as num).toDouble();
            final isProfitable = profit >= 0;

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
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
                            Text(asset['name'] ?? asset['ticker'],
                                style: GoogleFonts.manrope(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface)),
                            SizedBox(height: 2.h),
                            Text(
                              '${asset['ticker']} \u2022 ${asset['asset_class']} \u2022 ${asset['weight']}% of portfolio',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isProfitable
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isProfitable
                              ? '+${formatAmount(profit, currency)}'
                              : formatAmount(profit, currency),
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isProfitable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _MiniStat(
                          label: 'Invested',
                          value: formatAmount(contributed, currency),
                          cs: cs),
                      SizedBox(width: 12.w),
                      _MiniStat(
                          label: 'Expected Value',
                          value: formatAmount(expectedFinal, currency),
                          cs: cs),
                      SizedBox(width: 12.w),
                      _MiniStat(
                          label: 'Annual Return',
                          value: '${asset['expected_annual_return']}%',
                          cs: cs),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Volatility: ${asset['volatility']}%',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp, color: cs.onSurfaceVariant)),
                      Row(
                        children: [
                          Text('Optimistic: ',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  color: cs.onSurfaceVariant)),
                          Text(
                              formatAmount(
                                  (asset['optimistic_final'] as num)
                                      .toDouble(),
                                  currency),
                              style: GoogleFonts.manrope(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF10B981))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Chart ─────────────────────────────────────────────────────

class _ProjectionChart extends StatelessWidget {
  const _ProjectionChart({
    required this.optimistic,
    required this.expected,
    required this.pessimistic,
    required this.colorScheme,
    required this.currency,
  });
  final List<double> optimistic;
  final List<double> expected;
  final List<double> pessimistic;
  final ColorScheme colorScheme;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    if (expected.length < 2) {
      return Center(
          child: Text('Run the simulation to see results',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp, color: colorScheme.onSurfaceVariant)));
    }

    List<FlSpot> toSpots(List<double> data) =>
        data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    final allMax = optimistic.isNotEmpty
        ? optimistic.reduce(math.max)
        : expected.reduce(math.max);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max((expected.length / 5).floorToDouble(), 1),
              getTitlesWidget: (v, _) => Text(
                'Y${v.toInt()}',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: allMax * 1.1,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                formatAmount(s.y, currency),
                GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          _line(toSpots(optimistic), const Color(0xFF10B981)),
          _line(toSpots(expected), colorScheme.primary),
          _line(toSpots(pessimistic), const Color(0xFFF59E0B)),
        ],
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0,
            toIndex: 2,
            color: colorScheme.primary.withValues(alpha: 0.04),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.colorScheme,
    this.valueColor,
  });
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.cs,
  });
  final String label;
  final String value;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.sp, color: cs.onSurfaceVariant)),
          SizedBox(height: 2.h),
          Text(value,
              style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.currency,
    required this.colorScheme,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final AppCurrency currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface)),
        SizedBox(height: 4.h),
        Text(hint,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.4)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: InputDecoration(
            prefixText: '${currency.symbol} ',
            prefixStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp, color: colorScheme.onSurfaceVariant),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
