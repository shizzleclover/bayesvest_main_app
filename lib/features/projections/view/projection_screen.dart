import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../portfolio/controller/portfolio_controller.dart';

class ProjectionScreen extends ConsumerStatefulWidget {
  const ProjectionScreen({super.key});

  @override
  ConsumerState<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends ConsumerState<ProjectionScreen> {
  final _initialCtrl = TextEditingController(text: '10,000');
  final _monthlyCtrl = TextEditingController(text: '500');
  double _years = 10;

  @override
  void dispose() {
    _initialCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final currency = ref.watch(currencyProvider);

    final portfolio = portfolioAsync.asData?.value;
    final annualReturn = (portfolio?.expectedReturn1y ?? 0.08);
    const volatility = 0.12;

    final pv = _parse(_initialCtrl);
    final pmt = _parse(_monthlyCtrl);
    final years = _years.round();

    final optimistic = _project(pv, pmt, annualReturn + volatility, years);
    final expected = _project(pv, pmt, annualReturn, years);
    final pessimistic =
        _project(pv, pmt, math.max(annualReturn - volatility, 0.005), years);

    final finalExpected = expected.isNotEmpty ? expected.last : 0.0;

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
                'See how your investment could grow',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Inputs ────────────────────────────────────
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
                  children: [
                    _LabeledInput(
                      label: 'Initial investment',
                      controller: _initialCtrl,
                      currency: currency,
                      colorScheme: colorScheme,
                      onChanged: () => setState(() {}),
                    ),
                    SizedBox(height: 16.h),
                    _LabeledInput(
                      label: 'Monthly contribution',
                      controller: _monthlyCtrl,
                      currency: currency,
                      colorScheme: colorScheme,
                      onChanged: () => setState(() {}),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time horizon',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: colorScheme.onSurfaceVariant)),
                        Text('$years years',
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
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Result highlight ──────────────────────────
            AnimatedListItem(
              index: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.06),
                      colorScheme.tertiary.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: AppRadius.card,
                ),
                child: Column(
                  children: [
                    Text('Projected value in $years years',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant)),
                    SizedBox(height: 8.h),
                    Text(
                      formatAmount(finalExpected, currency),
                      style: GoogleFonts.manrope(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'based on ${(annualReturn * 100).toStringAsFixed(1)}% expected annual return',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Chart ─────────────────────────────────────
            AnimatedListItem(
              index: 3,
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
                        _LegendDot(color: const Color(0xFF10B981)),
                        SizedBox(width: 6.w),
                        Text('Optimistic',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: colorScheme.onSurfaceVariant)),
                        SizedBox(width: 16.w),
                        _LegendDot(color: colorScheme.primary),
                        SizedBox(width: 6.w),
                        Text('Expected',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: colorScheme.onSurfaceVariant)),
                        SizedBox(width: 16.w),
                        _LegendDot(color: const Color(0xFFF59E0B)),
                        SizedBox(width: 6.w),
                        Text('Pessimistic',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 220.h,
                      child: _ProjectionChart(
                        optimistic: optimistic,
                        expected: expected,
                        pessimistic: pessimistic,
                        colorScheme: colorScheme,
                        currency: currency,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Breakdown ─────────────────────────────────
            AnimatedListItem(
              index: 4,
              child: _BreakdownCard(
                years: years,
                optimistic: optimistic.isNotEmpty ? optimistic.last : 0,
                expected: finalExpected,
                pessimistic: pessimistic.isNotEmpty ? pessimistic.last : 0,
                totalContributed: pv + (pmt * 12 * years),
                currency: currency,
                colorScheme: colorScheme,
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  List<double> _project(double pv, double pmt, double r, int years) {
    final monthly = r / 12;
    final points = <double>[pv];
    var balance = pv;
    for (var m = 1; m <= years * 12; m++) {
      balance = balance * (1 + monthly) + pmt;
      if (m % 12 == 0) points.add(balance);
    }
    return points;
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
          child: Text('Adjust inputs above',
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
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

// ── Breakdown Card ────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.years,
    required this.optimistic,
    required this.expected,
    required this.pessimistic,
    required this.totalContributed,
    required this.currency,
    required this.colorScheme,
  });
  final int years;
  final double optimistic;
  final double expected;
  final double pessimistic;
  final double totalContributed;
  final AppCurrency currency;
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
          Text('After $years years',
              style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface)),
          SizedBox(height: 16.h),
          _Row(label: 'You contribute', value: formatAmount(totalContributed, currency), colorScheme: colorScheme),
          _Row(label: 'Optimistic scenario', value: formatAmount(optimistic, currency), colorScheme: colorScheme, valueColor: const Color(0xFF10B981)),
          _Row(label: 'Expected scenario', value: formatAmount(expected, currency), colorScheme: colorScheme, valueColor: colorScheme.primary),
          _Row(label: 'Pessimistic scenario', value: formatAmount(pessimistic, currency), colorScheme: colorScheme, valueColor: const Color(0xFFF59E0B)),
          SizedBox(height: 8.h),
          _Row(
            label: 'Expected growth',
            value: formatAmount(expected - totalContributed, currency),
            colorScheme: colorScheme,
            valueColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}

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

// ── Input helper ──────────────────────────────────────────────

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.controller,
    required this.currency,
    required this.colorScheme,
    required this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final AppCurrency currency;
  final ColorScheme colorScheme;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp, color: colorScheme.onSurfaceVariant)),
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
          onChanged: (_) => onChanged(),
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
