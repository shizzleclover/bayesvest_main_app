import 'package:flutter/material.dart';

/// Bayesvest color tokens following the "Editorial Advisory" design system.
///
/// Light mode derived directly from DESIGN.md.
/// Dark mode inspired by Betterment's dark theme (deep navy backgrounds,
/// muted primary, lighter text).
class AppColors {
  AppColors._();

  // ────────────────────────────────────────────────────────────
  //  LIGHT MODE
  // ────────────────────────────────────────────────────────────

  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF0050CB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0066FF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // ── Secondary ────────────────────────────────────────────
  static const Color secondary = Color(0xFF6B7280);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE9EDFF);
  static const Color onSecondaryContainer = Color(0xFF5E6572);

  // ── Tertiary ─────────────────────────────────────────────
  static const Color tertiary = Color(0xFF0D9488);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB7EAFF);
  static const Color onTertiaryContainer = Color(0xFF065F56);

  // ── Error ────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // ── Surface hierarchy (DESIGN.md §2 — "No-Line" tonal layering) ──
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFD8DAE4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4FA);
  static const Color surfaceContainer = Color(0xFFE9EDFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE2F2);
  static const Color surfaceContainerHighest = Color(0xFFD3D8E8);
  static const Color onSurface = Color(0xFF141B2B);
  static const Color onSurfaceVariant = Color(0xFF5E6572);

  // ── Background ───────────────────────────────────────────
  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF141B2B);

  // ── Outline ──────────────────────────────────────────────
  static const Color outline = Color(0xFF8E9099);
  static const Color outlineVariant = Color(0xFFC4C6D0);

  // ── Semantic ─────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color tertiaryFixed = Color(0xFFB7EAFF);

  // ── Shadow & Scrim (DESIGN.md §4 — tinted blue, not pure black) ──
  static const Color shadow = Color(0xFF141B2B);
  static const Color scrim = Color(0xFF141B2B);

  // ────────────────────────────────────────────────────────────
  //  DARK MODE  (Betterment-inspired deep navy)
  // ────────────────────────────────────────────────────────────

  // ── Primary ──────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF7EB0FF);
  static const Color darkOnPrimary = Color(0xFF002D6E);
  static const Color darkPrimaryContainer = Color(0xFF004AB5);
  static const Color darkOnPrimaryContainer = Color(0xFFD4E3FF);

  // ── Secondary ────────────────────────────────────────────
  static const Color darkSecondary = Color(0xFFBCC3CF);
  static const Color darkOnSecondary = Color(0xFF2D333D);
  static const Color darkSecondaryContainer = Color(0xFF3A4150);
  static const Color darkOnSecondaryContainer = Color(0xFFBCC3CF);

  // ── Tertiary ─────────────────────────────────────────────
  static const Color darkTertiary = Color(0xFF4FD1C5);
  static const Color darkOnTertiary = Color(0xFF003731);
  static const Color darkTertiaryContainer = Color(0xFF005048);
  static const Color darkOnTertiaryContainer = Color(0xFFB7EAFF);

  // ── Error ────────────────────────────────────────────────
  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF7F1D1D);
  static const Color darkErrorContainer = Color(0xFF991B1B);
  static const Color darkOnErrorContainer = Color(0xFFFEE2E2);

  // ── Surface hierarchy ────────────────────────────────────
  static const Color darkSurface = Color(0xFF0F1219);
  static const Color darkSurfaceDim = Color(0xFF0F1219);
  static const Color darkSurfaceContainerLowest = Color(0xFF090C12);
  static const Color darkSurfaceContainerLow = Color(0xFF171B24);
  static const Color darkSurfaceContainer = Color(0xFF1B2030);
  static const Color darkSurfaceContainerHigh = Color(0xFF252A3A);
  static const Color darkSurfaceContainerHighest = Color(0xFF303545);
  static const Color darkOnSurface = Color(0xFFE2E4EA);
  static const Color darkOnSurfaceVariant = Color(0xFFBCC3CF);

  // ── Background ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1219);
  static const Color darkOnBackground = Color(0xFFE2E4EA);

  // ── Outline ──────────────────────────────────────────────
  static const Color darkOutline = Color(0xFF8E9099);
  static const Color darkOutlineVariant = Color(0xFF3A4150);

  // ── Semantic ─────────────────────────────────────────────
  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkOnSuccess = Color(0xFF14532D);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkOnWarning = Color(0xFF78350F);
  static const Color darkTertiaryFixed = Color(0xFF1B4B5A);

  // ── Shadow & Scrim ───────────────────────────────────────
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkScrim = Color(0xFF000000);

  // ────────────────────────────────────────────────────────────
  //  COLOR SCHEME FACTORIES
  // ────────────────────────────────────────────────────────────

  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    scrim: scrim,
    surfaceDim: surfaceDim,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    shadow: darkShadow,
    scrim: darkScrim,
    surfaceDim: darkSurfaceDim,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
  );
}
