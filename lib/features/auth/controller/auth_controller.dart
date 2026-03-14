import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/utils/logger.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';

// ── Auth State ─────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  final bool hasCompletedOnboarding;
  const Authenticated(this.user, {this.hasCompletedOnboarding = true});
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ── Provider ───────────────────────────────────────────────

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

// ── Controller ─────────────────────────────────────────────

class AuthController extends Notifier<AuthState> {
  static const _tag = 'Auth';

  @override
  AuthState build() => const AuthInitial();

  /// Check whether a stored JWT exists. Called once from the splash screen.
  Future<void> checkAuth() async {
    AppLogger.info('checkAuth() called', tag: _tag);
    state = const AuthLoading();
    final tokenStorage = ref.read(tokenStorageProvider);
    final hasToken = await tokenStorage.hasTokens();
    AppLogger.debug('hasToken=$hasToken', tag: _tag);

    if (hasToken) {
      try {
        final dio = ref.read(dioProvider);
        await dio.get('/api/users/profile/');
        final email = await tokenStorage.getEmail() ?? '';
        AppLogger.info('Token valid, profile exists, email=$email', tag: _tag);
        state = Authenticated(
          User(id: '', email: email),
          hasCompletedOnboarding: true,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          final email = await tokenStorage.getEmail() ?? '';
          AppLogger.info('Token valid, no profile yet — needs onboarding', tag: _tag);
          state = Authenticated(
            User(id: '', email: email),
            hasCompletedOnboarding: false,
          );
        } else {
          AppLogger.warning(
            'checkAuth failed: ${e.response?.statusCode}',
            tag: _tag,
          );
          await tokenStorage.clearTokens();
          state = const Unauthenticated();
        }
      }
    } else {
      state = const Unauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    AppLogger.info('login() email=$email', tag: _tag);
    state = const AuthLoading();
    try {
      final service = ref.read(authServiceProvider);
      final tokenStorage = ref.read(tokenStorageProvider);

      final response = await service.login(
        email: email,
        password: password,
      );

      await tokenStorage.saveTokens(
        access: response.access,
        refresh: response.refresh,
      );
      await tokenStorage.saveEmail(response.user.email);

      // Check if user has a profile (returning vs new user).
      final dio = ref.read(dioProvider);
      bool onboarded = true;
      try {
        await dio.get('/api/users/profile/');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) onboarded = false;
      }

      AppLogger.info(
        'login() success email=${response.user.email} onboarded=$onboarded',
        tag: _tag,
      );
      state = Authenticated(response.user, hasCompletedOnboarding: onboarded);
    } on DioException catch (e) {
      final message = extractApiError(e, fallback: 'Login failed. Please try again.');
      AppLogger.error('login() failed: $message', tag: _tag, error: e);
      state = AuthError(message);
    } catch (e, st) {
      AppLogger.error('login() unexpected error', tag: _tag, error: e, stackTrace: st);
      state = AuthError(e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    AppLogger.info('register() email=$email', tag: _tag);
    state = const AuthLoading();
    try {
      final service = ref.read(authServiceProvider);
      final tokenStorage = ref.read(tokenStorageProvider);

      final response = await service.register(
        email: email,
        password: password,
      );

      await tokenStorage.saveTokens(
        access: response.access,
        refresh: response.refresh,
      );
      await tokenStorage.saveEmail(response.user.email);

      AppLogger.info('register() success — needs onboarding', tag: _tag);
      state = Authenticated(
        response.user,
        hasCompletedOnboarding: false,
      );
    } on DioException catch (e) {
      final message = extractApiError(e, fallback: 'Registration failed. Please try again.');
      AppLogger.error('register() failed: $message', tag: _tag, error: e);
      state = AuthError(message);
    } catch (e, st) {
      AppLogger.error('register() unexpected error', tag: _tag, error: e, stackTrace: st);
      state = AuthError(e.toString());
    }
  }

  /// Mark onboarding as complete (called after risk questionnaire).
  void markOnboardingComplete() {
    final current = state;
    if (current is Authenticated) {
      AppLogger.info('markOnboardingComplete()', tag: _tag);
      state = Authenticated(current.user, hasCompletedOnboarding: true);
    }
  }

  Future<void> logout() async {
    AppLogger.info('logout()', tag: _tag);
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearTokens();
    state = const Unauthenticated();
  }
}
