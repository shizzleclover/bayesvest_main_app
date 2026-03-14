import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/controller/auth_controller.dart';
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

/// Converts auth state changes into a [Listenable] that GoRouter
/// can subscribe to via [GoRouter.refreshListenable].
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Top-level router exposed as a Riverpod provider so it can
/// react to auth state changes for redirect guards.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final currentPath = state.matchedLocation;

      final isOnSplash = currentPath == AppRoutes.splash;
      final isOnAuth =
          currentPath == AppRoutes.login || currentPath == AppRoutes.register;
      final isOnOnboarding = currentPath == AppRoutes.onboardingProfile ||
          currentPath == AppRoutes.onboardingRisk;

      // While initialising or loading, stay on splash.
      if (authState is AuthInitial || authState is AuthLoading) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // Not authenticated → force login (unless already there).
      if (authState is Unauthenticated || authState is AuthError) {
        return isOnAuth ? null : AppRoutes.login;
      }

      // Authenticated — route depends on onboarding status.
      if (authState is Authenticated) {
        if (!authState.hasCompletedOnboarding) {
          // New user: send to onboarding from splash/auth screens.
          // Allow staying on onboarding routes.
          if (isOnSplash || isOnAuth) return AppRoutes.onboardingProfile;
          if (isOnOnboarding) return null;
        } else {
          // Returning user: don't allow splash, auth, or onboarding.
          if (isOnSplash || isOnAuth || isOnOnboarding) return AppRoutes.home;
        }
      }

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
});
