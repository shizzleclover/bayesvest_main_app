import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../auth/controller/auth_controller.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../portfolio/controller/portfolio_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final riskAsync = ref.watch(riskControllerProvider);
    final portfolioAsync = ref.watch(portfolioControllerProvider);

    final email = authState is Authenticated ? authState.user.email : '';
    final greeting = email.isNotEmpty ? email.split('@').first : 'Investor';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(riskControllerProvider);
            ref.invalidate(portfolioControllerProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),

                // ── Greeting ────────────────────────────────
                Text(
                  'Hello, $greeting',
                  style: GoogleFonts.manrope(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your intelligent portfolio advisor',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Risk card ───────────────────────────────
                riskAsync.when(
                  data: (risk) {
                    if (risk == null) {
                      return _InfoCard(
                        icon: Icons.shield_outlined,
                        title: 'Risk Assessment Pending',
                        subtitle:
                            'Complete the risk questionnaire to get started.',
                        colorScheme: colorScheme,
                      );
                    }
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
                          Text(
                            'Your Risk Profile',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          RiskBadge(
                            band: risk.riskScore,
                            rawScore: risk.rawScore,
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => _ShimmerCard(colorScheme: colorScheme),
                  error: (e, _) => _InfoCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load risk profile',
                    subtitle: e.toString(),
                    colorScheme: colorScheme,
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Portfolio quick stats ───────────────────
                portfolioAsync.when(
                  data: (portfolio) {
                    if (portfolio == null) return const SizedBox.shrink();
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
                          Text(
                            'Current Portfolio',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              _StatChip(
                                label: 'Expected Return',
                                value:
                                    '+${portfolio.expectedReturn1y.toStringAsFixed(1)}%',
                                color: colorScheme.tertiary,
                                colorScheme: colorScheme,
                              ),
                              SizedBox(width: 12.w),
                              _StatChip(
                                label: 'Assets',
                                value:
                                    '${portfolio.assetAllocation.length}',
                                color: colorScheme.primary,
                                colorScheme: colorScheme,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            portfolio.riskSummary,
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
                    );
                  },
                  loading: () => _ShimmerCard(colorScheme: colorScheme),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                SizedBox(height: 32.h),

                // ── CTA ─────────────────────────────────────
                GradientButton(
                  label: portfolioAsync.asData?.value != null
                      ? 'Regenerate Portfolio'
                      : 'Generate My Portfolio',
                  isLoading: portfolioAsync.isLoading,
                  onPressed: () async {
                    await ref
                        .read(portfolioControllerProvider.notifier)
                        .generate();
                    if (context.mounted) {
                      context.go(AppRoutes.portfolio);
                    }
                  },
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 28.w),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                SizedBox(height: 4.h),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.colorScheme,
  });
  final String label;
  final String value;
  final Color color;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.button,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant)),
            SizedBox(height: 4.h),
            Text(value,
                style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
