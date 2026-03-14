import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../auth/controller/auth_controller.dart';
import '../../onboarding/controller/onboarding_controller.dart';
import '../../portfolio/controller/portfolio_controller.dart';

// ── Static content ──────────────────────────────────────────

const _investingTips = <_TipData>[
  _TipData(
    icon: Icons.diversity_3_rounded,
    title: 'Diversify',
    body: 'Don\u0027t put all your eggs in one basket. Spreading investments across asset classes reduces risk.',
  ),
  _TipData(
    icon: Icons.calendar_month_rounded,
    title: 'Invest consistently',
    body: 'Dollar-cost averaging \u2014 investing a fixed amount regularly \u2014 smooths out market volatility over time.',
  ),
  _TipData(
    icon: Icons.timer_rounded,
    title: 'Think long-term',
    body: 'Markets fluctuate daily, but historically they trend upward over decades. Patience pays.',
  ),
  _TipData(
    icon: Icons.savings_rounded,
    title: 'Emergency fund first',
    body: 'Before investing, set aside 3\u20136 months of living expenses so you never have to sell at a loss.',
  ),
  _TipData(
    icon: Icons.psychology_rounded,
    title: 'Control emotions',
    body: 'Fear and greed drive bad decisions. Stick to your plan and avoid panic selling during downturns.',
  ),
];

const _glossary = <_GlossaryItem>[
  _GlossaryItem(
    term: 'ETF',
    definition: 'Exchange-Traded Fund \u2014 a basket of assets (stocks, bonds, etc.) that trades on an exchange like a single stock. Great for instant diversification.',
  ),
  _GlossaryItem(
    term: 'Volatility',
    definition: 'How much an asset\u0027s price swings up and down. Higher volatility means bigger gains OR bigger losses.',
  ),
  _GlossaryItem(
    term: 'Risk Tolerance',
    definition: 'The degree of price fluctuation you can stomach without panic-selling. Knowing yours is key to choosing the right portfolio.',
  ),
  _GlossaryItem(
    term: 'Portfolio Allocation',
    definition: 'How your money is divided across different asset types (stocks, bonds, crypto, etc.). The mix depends on your goals and risk level.',
  ),
  _GlossaryItem(
    term: 'Compound Interest',
    definition: 'Earning returns on your returns. The earlier you start investing, the more time compounding has to grow your wealth exponentially.',
  ),
  _GlossaryItem(
    term: 'Suitability Score',
    definition: 'A Bayesian probability (0\u2013100%) showing how well an asset fits your specific risk profile. Higher is better for you.',
  ),
];

class _TipData {
  final IconData icon;
  final String title;
  final String body;
  const _TipData({required this.icon, required this.title, required this.body});
}

class _GlossaryItem {
  final String term;
  final String definition;
  const _GlossaryItem({required this.term, required this.definition});
}

// ── Screen ──────────────────────────────────────────────────

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
                AnimatedListItem(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Risk card ───────────────────────────────
                AnimatedListItem(
                  index: 1,
                  child: riskAsync.when(
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
                )),

                SizedBox(height: 20.h),

                // ── Portfolio quick stats ───────────────────
                AnimatedListItem(
                  index: 2,
                  child: portfolioAsync.when(
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
                )),

                SizedBox(height: 32.h),

                // ── CTA ─────────────────────────────────────
                AnimatedListItem(
                  index: 3,
                  child: GradientButton(
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
                )),

                SizedBox(height: 36.h),

                // ── Investing Tips ──────────────────────────
                AnimatedListItem(
                  index: 4,
                  child: Text(
                    'Investing Tips',
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 165.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: _investingTips.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, i) {
                      final tip = _investingTips[i];
                      return AnimatedListItem(
                        index: i + 5,
                        child: Container(
                          width: 260.w,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: AppRadius.card,
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(tip.icon,
                                    size: 18.w, color: colorScheme.primary),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                tip.title,
                                style: GoogleFonts.manrope(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                tip.body,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 36.h),

                // ── Glossary ────────────────────────────────
                AnimatedListItem(
                  index: 10,
                  child: Text(
                    'Key Terms',
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                AnimatedListItem(
                  index: 11,
                  child: Text(
                    'Understand the basics of investing',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                ..._glossary.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return AnimatedListItem(
                    index: i + 12,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: AppRadius.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.term,
                            style: GoogleFonts.manrope(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item.definition,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 36.h),

                // ── Did You Know ────────────────────────────
                AnimatedListItem(
                  index: 18,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.06),
                          colorScheme.tertiary.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: AppRadius.card,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            size: 24.w, color: colorScheme.primary),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Did you know?',
                                style: GoogleFonts.manrope(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'If you invested \$1,000 in the S&P 500 in 1990 and '
                                'reinvested all dividends, it would be worth over '
                                '\$20,000 today. That\u0027s the power of long-term '
                                'compound growth.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
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
