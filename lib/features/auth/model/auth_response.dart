import 'user_model.dart';

/// Response from `POST /api/users/auth/login/` and `/register/`.
class AuthResponse {
  final String access;
  final String refresh;
  final User user;

  const AuthResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
