import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bayesvest typography system — "Editorial Authority" (DESIGN.md §3).
///
/// **Manrope** — display & headline (bold, commanding, editorial hooks).
/// **Plus Jakarta Sans** — title, body & label (functional reading, calm rhythm).
///
/// All sizes use ScreenUtil `.sp` for responsive scaling.
/// Base design frame: 375 × 812.
class AppTextStyles {
  AppTextStyles._();

  // ────────────────────────────────────────────────────────────
  //  DISPLAY — Manrope (The Bold Statement)
  //  Heavy weight, commanding the page.
  // ────────────────────────────────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.manrope(
    fontSize: 56.sp,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.manrope(
    fontSize: 45.sp,
    fontWeight: FontWeight.w700,
    height: 1.16,
    letterSpacing: -0.25,
  );

  static TextStyle get displaySmall => GoogleFonts.manrope(
    fontSize: 36.sp,
    fontWeight: FontWeight.w700,
    height: 1.22,
  );

  // ────────────────────────────────────────────────────────────
  //  HEADLINE — Manrope (The Navigator)
  //  Editorial "hook" for new sections.
  // ────────────────────────────────────────────────────────────

  static TextStyle get headlineLarge => GoogleFonts.manrope(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.manrope(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static TextStyle get headlineSmall => GoogleFonts.manrope(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ────────────────────────────────────────────────────────────
  //  TITLE — Plus Jakarta Sans
  //  Sub-section headers and card titles.
  // ────────────────────────────────────────────────────────────

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // ────────────────────────────────────────────────────────────
  //  BODY — Plus Jakarta Sans (The Advisor)
  //  Workhorse for recommendations. Line height ~1.6 is
  //  non-negotiable for a "calm" reading experience.
  // ────────────────────────────────────────────────────────────

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // ────────────────────────────────────────────────────────────
  //  LABEL — Plus Jakarta Sans (The Detail)
  //  Always in onSecondaryContainer (#5E6572) — present
  //  but never distracting.
  // ────────────────────────────────────────────────────────────

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ────────────────────────────────────────────────────────────
  //  TEXT THEME (plug into ThemeData)
  // ────────────────────────────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
