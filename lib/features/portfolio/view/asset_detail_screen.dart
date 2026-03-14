import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../controller/portfolio_controller.dart';
import '../model/asset_reasoning.dart';

class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioAsync = ref.watch(portfolioControllerProvider);

    final asset = portfolioAsync.asData?.value?.reasoning
        .cast<AssetReasoning?>()
        .firstWhere((a) => a?.ticker == ticker, orElse: () => null);

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ticker)),
        body: Center(
          child: Text('Asset not found.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, color: colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 160.h,
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
                        Text(
                          asset.ticker,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
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

                  // ── Stats row ─────────────────────────────
                  Row(
                    children: [
                      _StatTile(
                        label: 'Allocation',
                        value: '${asset.allocationPct.toStringAsFixed(1)}%',
                        colorScheme: colorScheme,
                      ),
                      SizedBox(width: 12.w),
                      _StatTile(
                        label: 'Exp. Return',
                        value:
                            '+${asset.expectedReturn.toStringAsFixed(1)}%',
                        colorScheme: colorScheme,
                      ),
                      SizedBox(width: 12.w),
                      _StatTile(
                        label: 'Volatility',
                        value:
                            '${asset.volatility.toStringAsFixed(1)}%',
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  // ── Suitability gauge ─────────────────────
                  _SuitabilityGauge(
                    score: asset.suitabilityScore,
                    colorScheme: colorScheme,
                  ),

                  SizedBox(height: 28.h),

                  // ── Full explanation ──────────────────────
                  Text(
                    'Why this asset?',
                    style: GoogleFonts.manrope(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    asset.explanation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.65,
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

// ── Private helpers ─────────────────────────────────────────

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

class _SuitabilityGauge extends StatelessWidget {
  const _SuitabilityGauge({
    required this.score,
    required this.colorScheme,
  });
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
        ],
      ),
    );
  }
}
