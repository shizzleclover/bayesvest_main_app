import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
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
];

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final riskAsync = ref.watch(riskControllerProvider);

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
              onRefresh: () =>
                  ref.read(portfolioControllerProvider.notifier).generate(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    Text(
                      'Your Portfolio',
                      style: GoogleFonts.manrope(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Risk summary card ────────────────────
                    _RiskSummaryCard(
                      portfolio: portfolio,
                      riskScore: riskAsync.asData?.value?.riskScore,
                      colorScheme: colorScheme,
                    ),

                    SizedBox(height: 24.h),

                    // ── Donut chart ──────────────────────────
                    _AllocationChart(portfolio: portfolio),

                    SizedBox(height: 24.h),

                    // ── Per-asset cards ──────────────────────
                    Text(
                      'Asset Breakdown',
                      style: GoogleFonts.manrope(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    ...portfolio.reasoning.map((asset) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _AssetCard(
                            asset: asset,
                            colorScheme: colorScheme,
                            onTap: () => context.push(
                                AppRoutes.assetDetailPath(asset.ticker)),
                          ),
                        )),

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
            RiskBadge(riskScore: riskScore!),
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
  const _AllocationChart({required this.portfolio});
  final Portfolio portfolio;

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
                  Text(
                    '${e.key} ${(e.value * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
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
  });
  final AssetReasoning asset;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.12),
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
              ],
            ),
            SizedBox(height: 16.h),
            // Suitability bar
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
