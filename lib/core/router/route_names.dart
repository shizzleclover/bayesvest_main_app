/// Centralised route paths — no magic strings in navigation calls.
class AppRoutes {
  AppRoutes._();

  // Pre-auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Onboarding (first-time after registration)
  static const String onboardingProfile = '/onboarding/profile';
  static const String onboardingRisk = '/onboarding/risk';

  // Main app (bottom nav tabs)
  static const String home = '/home';
  static const String portfolio = '/portfolio';
  static const String profile = '/profile';

  // Sub-pages (no bottom nav)
  static const String assetDetail = '/portfolio/:ticker';
  static const String editProfile = '/profile/edit';
  static const String retakeRisk = '/profile/retake-risk';
  static const String settings = '/settings';
  static const String projections = '/projections';
  static const String portfolioHistory = '/portfolio/history';
  static const String goals = '/goals';
  static const String watchlist = '/watchlist';

  /// Build asset detail path for a given [ticker].
  static String assetDetailPath(String ticker) => '/portfolio/$ticker';
}
