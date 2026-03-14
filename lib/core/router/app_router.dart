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
import 'route_transitions.dart';

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

      if (authState is AuthInitial || authState is AuthLoading) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      if (authState is Unauthenticated || authState is AuthError) {
        return isOnAuth ? null : AppRoutes.login;
      }

      if (authState is Authenticated) {
        if (!authState.hasCompletedOnboarding) {
          if (isOnSplash || isOnAuth) return AppRoutes.onboardingProfile;
          if (isOnOnboarding) return null;
        } else {
          if (isOnSplash || isOnAuth || isOnOnboarding) return AppRoutes.home;
        }
      }

      return null;
    },

    routes: [
      // ── Pre-Auth ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            fadeTransition(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            fadeSlideTransition(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            fadeSlideTransition(state: state, child: const RegisterScreen()),
      ),

      // ── Onboarding (horizontal slide like a wizard) ────────
      GoRoute(
        path: AppRoutes.onboardingProfile,
        pageBuilder: (context, state) => slideHorizontalTransition(
            state: state, child: const FinancialProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboardingRisk,
        pageBuilder: (context, state) => slideHorizontalTransition(
            state: state, child: const RiskQuestionnaireScreen()),
      ),

      // ── Main App (Bottom Nav Shell) ────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    fadeTransition(state: state, child: const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.portfolio,
                pageBuilder: (context, state) => fadeTransition(
                    state: state, child: const PortfolioScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => fadeTransition(
                    state: state, child: const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── Sub-Pages (slide up, no bottom nav) ────────────────
      GoRoute(
        path: AppRoutes.assetDetail,
        pageBuilder: (context, state) => slideUpTransition(
          state: state,
          child: AssetDetailScreen(
            ticker: state.pathParameters['ticker']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => slideUpTransition(
            state: state, child: const EditProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.retakeRisk,
        pageBuilder: (context, state) => slideUpTransition(
            state: state, child: const RetakeRiskScreen()),
      ),
    ],
  );
});
