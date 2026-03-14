import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../../core/widgets/currency_toggle.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../auth/controller/auth_controller.dart';
import '../../onboarding/controller/onboarding_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authControllerProvider);
    final riskAsync = ref.watch(riskControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    final email = authState is Authenticated ? authState.user.email : '';
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              AnimatedListItem(
                index: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.manrope(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.settings),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          borderRadius: AppRadius.card,
                        ),
                        child: Icon(Icons.settings_rounded,
                            size: 22.w, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // ── User info card ────────────────────────────
              AnimatedListItem(
                index: 1,
                child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: AppRadius.card,
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26.w,
                      backgroundColor:
                          colorScheme.primaryContainer.withValues(alpha: 0.15),
                      child: Icon(Icons.person_outline_rounded,
                          color: colorScheme.primary, size: 28.w),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.isNotEmpty ? email : 'Investor',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          riskAsync.when(
                            data: (risk) {
                              if (risk == null) {
                                return Text('No risk assessment',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.sp,
                                        color: colorScheme.onSurfaceVariant));
                              }
                              return RiskBadge(
                                band: risk.riskScore,
                                rawScore: risk.rawScore,
                              );
                            },
                            loading: () => SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

              SizedBox(height: 24.h),

              // ── Financial summary ─────────────────────────
              AnimatedListItem(
                index: 2,
                child: profileAsync.when(
                data: (profile) {
                  if (profile == null) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: AppRadius.card,
                      ),
                      child: Text(
                        'No financial profile yet.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: colorScheme.onSurfaceVariant),
                      ),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Financial Summary',
                                style: GoogleFonts.manrope(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const CurrencyToggle(),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _SummaryRow(
                            label: 'Age',
                            value: '${profile.age}',
                            colorScheme: colorScheme),
                        _SummaryRow(
                            label: 'Income',
                            value: formatAmount(profile.income, currency),
                            colorScheme: colorScheme),
                        _SummaryRow(
                            label: 'Savings',
                            value: formatAmount(profile.savings, currency),
                            colorScheme: colorScheme),
                        if (profile.goals != null)
                          _SummaryRow(
                              label: 'Goal',
                              value: profile.goals!,
                              colorScheme: colorScheme),
                        if (profile.horizon != null)
                          _SummaryRow(
                              label: 'Horizon',
                              value: profile.horizon!,
                              colorScheme: colorScheme),
                      ],
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 80.h,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              )),

              SizedBox(height: 32.h),

              // ── Action buttons ────────────────────────────
              AnimatedListItem(
                index: 3,
                child: _ActionTile(
                  icon: Icons.edit_note_rounded,
                  label: 'Edit Financial Profile',
                  onTap: () => context.push(AppRoutes.editProfile),
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(height: 12.h),
              AnimatedListItem(
                index: 4,
                child: _ActionTile(
                  icon: Icons.shield_outlined,
                  label: 'Retake Risk Assessment',
                  onTap: () => context.push(AppRoutes.retakeRisk),
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(height: 12.h),
              AnimatedListItem(
                index: 5,
                child: _ActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  colorScheme: colorScheme,
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });
  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp, color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final fgColor = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Icon(icon, color: fgColor, size: 22.w),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: fgColor)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant, size: 22.w),
          ],
        ),
      ),
    );
  }
}
