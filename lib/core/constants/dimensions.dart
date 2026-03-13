import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

/// Bayesvest spacing, radii, and shadow tokens from DESIGN.md §4–§5.
///
/// Spacing uses a 4 px base grid scaled through ScreenUtil.
/// Border radii follow the strict 10 / 12 / 16 scale.
/// Shadows use tinted blue (#141B2B) instead of pure black.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 24.w;
  static double get xxl => 32.w;
  static double get xxxl => 48.w;

  static EdgeInsets get paddingSm => EdgeInsets.all(sm);
  static EdgeInsets get paddingMd => EdgeInsets.all(md);
  static EdgeInsets get paddingLg => EdgeInsets.all(lg);
  static EdgeInsets get paddingXl => EdgeInsets.all(xl);

  static EdgeInsets get horizontalSm => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get horizontalMd => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get horizontalLg => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get horizontalXl => EdgeInsets.symmetric(horizontal: xl);

  static EdgeInsets get verticalSm => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get verticalMd => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get verticalLg => EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get verticalXl => EdgeInsets.symmetric(vertical: xl);

  /// Screen-edge horizontal padding (consistent gutter).
  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 20.w);
}

/// DESIGN.md §5: "No Sharp Corners" — 10 / 12 / 16 radius scale.
class AppRadius {
  AppRadius._();

  /// Inputs (DESIGN.md §5: 10 px).
  static BorderRadius get input => BorderRadius.circular(10.r);

  /// Buttons (DESIGN.md §5: 12 px).
  static BorderRadius get button => BorderRadius.circular(12.r);

  /// Cards (DESIGN.md §5: 16 px).
  static BorderRadius get card => BorderRadius.circular(16.r);

  /// Pill shape for chips and tags.
  static BorderRadius get pill => BorderRadius.circular(100.r);

  /// Bottom sheets and modals.
  static BorderRadius get sheet =>
      BorderRadius.vertical(top: Radius.circular(24.r));
}

/// DESIGN.md §4: "Tonal Layering" — tinted blue shadows, not pure black.
class AppShadows {
  AppShadows._();

  /// Subtle card elevation (2 % opacity, 16 px blur).
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.02),
      blurRadius: 16.r,
      offset: Offset(0, 4.h),
    ),
  ];

  /// Medium elevation for floating elements (3 % opacity, 24 px blur).
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.03),
      blurRadius: 24.r,
      offset: Offset(0, 8.h),
    ),
  ];

  /// Floating modals (DESIGN.md §4: 4 % opacity, 40 px blur).
  static List<BoxShadow> get modal => [
    BoxShadow(
      color: AppColors.shadow.withValues(alpha: 0.04),
      blurRadius: 40.r,
      offset: Offset(0, 12.h),
    ),
  ];
}
