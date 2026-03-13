import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/register_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/onboarding/view/financial_profile_screen.dart';
import '../../features/onboarding/view/risk_questionnaire_screen.dart';
import '../../features/portfolio/view/asset_detail_screen.dart';
import '../../features/portfolio/view/portfolio_screen.dart';
import '../../features/profile/view/edit_profile_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/profile/view/retake_risk_screen.dart';
import '../../features/splash/view/splash_screen.dart';
import '../widgets/main_shell.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Top-level [GoRouter] configuration.
///
/// Route structure mirrors `screen_map.md`:
///  - Pre-auth: splash, login, register
///  - Onboarding: financial profile, risk questionnaire
///  - Main app: [StatefulShellRoute] with bottom nav (home, portfolio, profile)
///  - Sub-pages: asset detail, edit profile, retake risk (full-screen, no nav)
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // ── Auth redirect ────────────────────────────────────────
  // TODO: Wire to auth state (Riverpod provider) once auth service is built.
  // Currently passes through — every route is reachable.
  redirect: (BuildContext context, GoRouterState state) {
    return null;
  },

  routes: [
    // ── Pre-Auth ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Onboarding ─────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboardingProfile,
      builder: (context, state) => const FinancialProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingRisk,
      builder: (context, state) => const RiskQuestionnaireScreen(),
    ),

    // ── Main App (Bottom Nav Shell) ────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // Tab 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 1 — Portfolio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.portfolio,
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),

        // Tab 2 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Sub-Pages (full-screen, no bottom nav) ─────────────
    GoRoute(
      path: AppRoutes.assetDetail,
      builder: (context, state) => AssetDetailScreen(
        ticker: state.pathParameters['ticker']!,
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.retakeRisk,
      builder: (context, state) => const RetakeRiskScreen(),
    ),
  ],
);
