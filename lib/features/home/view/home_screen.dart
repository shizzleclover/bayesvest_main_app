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
import '../../portfolio/controller/drift_controller.dart';
import '../../portfolio/controller/portfolio_controller.dart';
import '../controller/news_controller.dart';
import '../model/news_article.dart';

// ── Static content ──────────────────────────────────────────

const _investingTips = <_TipData>[
  _TipData(Icons.diversity_3_rounded, 'Diversify',
      'Don\u0027t put all your eggs in one basket. Spreading investments across asset classes reduces risk.'),
  _TipData(Icons.calendar_month_rounded, 'Invest consistently',
      'Dollar-cost averaging \u2014 investing a fixed amount regularly \u2014 smooths out market volatility over time.'),
  _TipData(Icons.timer_rounded, 'Think long-term',
      'Markets fluctuate daily, but historically they trend upward over decades. Patience pays.'),
  _TipData(Icons.savings_rounded, 'Emergency fund first',
      'Before investing, set aside 3\u20136 months of living expenses so you never have to sell at a loss.'),
  _TipData(Icons.psychology_rounded, 'Control emotions',
      'Fear and greed drive bad decisions. Stick to your plan and avoid panic selling during downturns.'),
];

const _glossary = <_GlossaryItem>[
  _GlossaryItem('ETF', 'Exchange-Traded Fund \u2014 a basket of assets that trades on an exchange like a single stock. Great for instant diversification.'),
  _GlossaryItem('Volatility', 'How much an asset\u0027s price swings up and down. Higher volatility means bigger gains OR bigger losses.'),
  _GlossaryItem('Risk Tolerance', 'The degree of price fluctuation you can stomach without panic-selling. Knowing yours is key to choosing the right portfolio.'),
  _GlossaryItem('Portfolio Allocation', 'How your money is divided across different asset types. The mix depends on your goals and risk level.'),
  _GlossaryItem('Compound Interest', 'Earning returns on your returns. The earlier you start investing, the more time compounding has to grow your wealth.'),
  _GlossaryItem('Suitability Score', 'A Bayesian probability (0\u2013100%) showing how well an asset fits your specific risk profile.'),
];

class _TipData {
  final IconData icon;
  final String title;
  final String body;
  const _TipData(this.icon, this.title, this.body);
}

class _GlossaryItem {
  final String term;
  final String definition;
  const _GlossaryItem(this.term, this.definition);
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
    final driftAsync = ref.watch(driftProvider);
    final newsAsync = ref.watch(newsProvider);

    final email = authState is Authenticated ? authState.user.email : '';
    final greeting = email.isNotEmpty ? email.split('@').first : 'Investor';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(riskControllerProvider);
            ref.invalidate(portfolioControllerProvider);
            ref.invalidate(driftProvider);
            ref.invalidate(newsProvider);
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
                      Text('Hello, $greeting',
                          style: GoogleFonts.manrope(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface)),
                      SizedBox(height: 4.h),
                      Text('Your intelligent portfolio advisor',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Rebalancing alert ───────────────────────
                if (driftAsync.asData?.value?.shouldRebalance == true)
                  AnimatedListItem(
                    index: 1,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 20.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sync_problem_rounded,
                              size: 24.w, color: const Color(0xFFF59E0B)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Portfolio may need rebalancing',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface)),
                                SizedBox(height: 2.h),
                                Text(
                                  'Your portfolio is ${driftAsync.asData!.value!.portfolioAgeDays} days old. Tap to regenerate.',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.sp,
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await ref.read(portfolioControllerProvider.notifier).generate();
                              if (context.mounted) context.go(AppRoutes.portfolio);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: AppRadius.pill,
                              ),
                              child: Text('Rebalance',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Risk card ───────────────────────────────
                AnimatedListItem(
                  index: 2,
                  child: riskAsync.when(
                    data: (risk) {
                      if (risk == null) {
                        return _InfoCard(
                            icon: Icons.shield_outlined,
                            title: 'Risk Assessment Pending',
                            subtitle: 'Complete the risk questionnaire to get started.',
                            colorScheme: colorScheme);
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
                            Text('Your Risk Profile',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant)),
                            SizedBox(height: 12.h),
                            RiskBadge(band: risk.riskScore, rawScore: risk.rawScore),
                          ],
                        ),
                      );
                    },
                    loading: () => _ShimmerCard(colorScheme: colorScheme),
                    error: (e, _) => _InfoCard(
                        icon: Icons.error_outline_rounded,
                        title: 'Could not load risk profile',
                        subtitle: e.toString(),
                        colorScheme: colorScheme),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Portfolio quick stats ───────────────────
                AnimatedListItem(
                  index: 3,
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
                            Text('Current Portfolio',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant)),
                            SizedBox(height: 16.h),
                            Row(children: [
                              _StatChip(
                                  label: 'Expected Return',
                                  value: '+${portfolio.expectedReturn1y.toStringAsFixed(1)}%',
                                  color: colorScheme.tertiary,
                                  colorScheme: colorScheme),
                              SizedBox(width: 12.w),
                              _StatChip(
                                  label: 'Assets',
                                  value: '${portfolio.assetAllocation.length}',
                                  color: colorScheme.primary,
                                  colorScheme: colorScheme),
                            ]),
                          ],
                        ),
                      );
                    },
                    loading: () => _ShimmerCard(colorScheme: colorScheme),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                SizedBox(height: 28.h),

                // ── CTA ─────────────────────────────────────
                AnimatedListItem(
                  index: 4,
                  child: GradientButton(
                    label: portfolioAsync.asData?.value != null
                        ? 'Regenerate Portfolio'
                        : 'Generate My Portfolio',
                    isLoading: portfolioAsync.isLoading,
                    onPressed: () async {
                      await ref.read(portfolioControllerProvider.notifier).generate();
                      if (context.mounted) context.go(AppRoutes.portfolio);
                    },
                  ),
                ),

                SizedBox(height: 28.h),

                // ── Quick actions grid ──────────────────────
                AnimatedListItem(
                  index: 5,
                  child: Row(
                    children: [
                      _QuickAction(
                        icon: Icons.trending_up_rounded,
                        label: 'Projections',
                        colorScheme: colorScheme,
                        onTap: () => context.push(AppRoutes.projections),
                      ),
                      SizedBox(width: 12.w),
                      _QuickAction(
                        icon: Icons.flag_rounded,
                        label: 'Goals',
                        colorScheme: colorScheme,
                        onTap: () => context.push(AppRoutes.goals),
                      ),
                      SizedBox(width: 12.w),
                      _QuickAction(
                        icon: Icons.bookmark_rounded,
                        label: 'Watchlist',
                        colorScheme: colorScheme,
                        onTap: () => context.push(AppRoutes.watchlist),
                      ),
                      SizedBox(width: 12.w),
                      _QuickAction(
                        icon: Icons.history_rounded,
                        label: 'History',
                        colorScheme: colorScheme,
                        onTap: () => context.push(AppRoutes.portfolioHistory),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Market News ─────────────────────────────
                AnimatedListItem(
                  index: 6,
                  child: Text('Market News',
                      style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 140.h,
                  child: newsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Center(
                      child: Text('News unavailable',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
                    ),
                    data: (articles) {
                      if (articles.isEmpty) {
                        return Center(
                          child: Text('No news right now',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
                        );
                      }
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: articles.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, i) =>
                            _NewsCard(article: articles[i], colorScheme: colorScheme),
                      );
                    },
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Investing Tips ──────────────────────────
                AnimatedListItem(
                  index: 7,
                  child: Text('Investing Tips',
                      style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 165.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _investingTips.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, i) {
                      final tip = _investingTips[i];
                      return Container(
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
                                color: colorScheme.primaryContainer.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(tip.icon, size: 18.w, color: colorScheme.primary),
                            ),
                            SizedBox(height: 12.h),
                            Text(tip.title,
                                style: GoogleFonts.manrope(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface)),
                            SizedBox(height: 6.h),
                            Text(tip.body,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.45),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 32.h),

                // ── Key Terms ───────────────────────────────
                AnimatedListItem(
                  index: 8,
                  child: Text('Key Terms',
                      style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                ),
                SizedBox(height: 14.h),

                ..._glossary.asMap().entries.map((entry) {
                  final item = entry.value;
                  return Container(
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
                        Text(item.term,
                            style: GoogleFonts.manrope(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary)),
                        SizedBox(height: 6.h),
                        Text(item.definition,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5)),
                      ],
                    ),
                  );
                }),

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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.w, color: colorScheme.primary),
              ),
              SizedBox(height: 8.h),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article, required this.colorScheme});
  final NewsArticle article;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title,
              style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          Expanded(
            child: Text(article.summary,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(article.source,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary),
                    overflow: TextOverflow.ellipsis),
              ),
              Text(article.timeAgo,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

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
      child: Row(children: [
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
                      fontSize: 13.sp, color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ]),
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
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
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
                    fontSize: 18.sp, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
