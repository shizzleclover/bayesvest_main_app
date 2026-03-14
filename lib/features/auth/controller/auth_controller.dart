import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../model/user_model.dart';
import '../service/auth_service.dart';

 

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
  const Authenticated(this.user);
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
  @override
  AuthState build() => const AuthInitial();

  /// Check whether a stored JWT exists. Called once from the splash screen.
  Future<void> checkAuth() async {
    state = const AuthLoading();
    final tokenStorage = ref.read(tokenStorageProvider);
    final hasToken = await tokenStorage.hasTokens();

    if (hasToken) {
      // Token exists — attempt to validate by fetching profile.
      // If the token is expired the interceptor will clear it and
      // a DioException (401) will land in the catch block.
      try {
        final dio = ref.read(dioProvider);
        await dio.get('/api/users/profile/');
        // If we get here the token is valid. We don't have user
        // info cached, so build a minimal User from the token claims
        // (id stored in secure storage isn't available; email will
        // be fetched on the home screen). For now, mark authenticated.
        final email = await tokenStorage.getEmail() ?? '';
        state = Authenticated(User(id: '', email: email));
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          final email = await tokenStorage.getEmail() ?? '';
          state = Authenticated(User(id: '', email: email));
        } else {
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

      state = Authenticated(response.user);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Login failed. Please try again.';
      state = AuthError(message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
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

      state = Authenticated(response.user);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Registration failed. Please try again.';
      state = AuthError(message);
    }
  }

  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearTokens();
    state = const Unauthenticated();
  }
}
