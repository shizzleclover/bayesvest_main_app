import 'package:flutter_dotenv/flutter_dotenv.dart';

/// All API endpoint paths in one place.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // ── Auth ─────────────────────────────────────────────────
  static const String register = '/api/users/auth/register/';
  static const String login = '/api/users/auth/login/';

  // ── Profile & Risk ──────────────────────────────────────
  static const String profile = '/api/users/profile/';
  static const String risk = '/api/users/risk/';

  // ── Portfolio ────────────────────────────────────────────
  static const String generatePortfolio = '/api/portfolio/generate/';
}
