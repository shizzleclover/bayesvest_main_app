import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../auth/controller/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // ── Appearance ────────────────────────────────
            AnimatedListItem(
              index: 0,
              child: _SectionLabel(text: 'Appearance', colorScheme: colorScheme),
            ),
            SizedBox(height: 12.h),
            AnimatedListItem(
              index: 1,
              child: _ThemeSelector(
                current: themeMode,
                colorScheme: colorScheme,
                onChanged: (m) =>
                    ref.read(themeProvider.notifier).setTheme(m),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Currency ──────────────────────────────────
            AnimatedListItem(
              index: 2,
              child: _SectionLabel(text: 'Currency', colorScheme: colorScheme),
            ),
            SizedBox(height: 12.h),
            AnimatedListItem(
              index: 3,
              child: _CurrencySelector(
                current: currency,
                colorScheme: colorScheme,
                onChanged: (c) =>
                    ref.read(currencyProvider.notifier).setCurrency(c),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Account ───────────────────────────────────
            AnimatedListItem(
              index: 4,
              child: _SectionLabel(text: 'Account', colorScheme: colorScheme),
            ),
            SizedBox(height: 12.h),
            AnimatedListItem(
              index: 5,
              child: _SettingsTile(
                icon: Icons.edit_note_rounded,
                label: 'Edit Financial Profile',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.editProfile),
              ),
            ),
            SizedBox(height: 8.h),
            AnimatedListItem(
              index: 6,
              child: _SettingsTile(
                icon: Icons.shield_outlined,
                label: 'Retake Risk Assessment',
                colorScheme: colorScheme,
                onTap: () => context.push(AppRoutes.retakeRisk),
              ),
            ),

            SizedBox(height: 28.h),

            AnimatedListItem(
              index: 7,
              child: _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                colorScheme: colorScheme,
                isDestructive: true,
                onTap: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ),

            SizedBox(height: 32.h),

            // ── App info ──────────────────────────────────
            Center(
              child: Text(
                'Bayesvest v0.1.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colorScheme});
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ── Theme selector ────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.current,
    required this.colorScheme,
    required this.onChanged,
  });
  final ThemeMode current;
  final ColorScheme colorScheme;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: ThemeMode.values.map((m) {
          final selected = m == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: AppRadius.card,
                ),
                child: Column(
                  children: [
                    Icon(
                      m == ThemeMode.light
                          ? Icons.light_mode_rounded
                          : m == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : Icons.brightness_auto_rounded,
                      size: 22.w,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      m == ThemeMode.system
                          ? 'System'
                          : m == ThemeMode.light
                              ? 'Light'
                              : 'Dark',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Currency selector ─────────────────────────────────────────

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.current,
    required this.colorScheme,
    required this.onChanged,
  });
  final AppCurrency current;
  final ColorScheme colorScheme;
  final ValueChanged<AppCurrency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: AppCurrency.values.map((c) {
          final selected = c == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: AppRadius.card,
                ),
                child: Text(
                  '${c.symbol}  ${c.code}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Reusable tile ─────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
    this.isDestructive = false,
  });
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive ? colorScheme.error : colorScheme.onSurface;
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
            Icon(icon, color: fg, size: 22.w),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: fg)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant, size: 22.w),
          ],
        ),
      ),
    );
  }
}
