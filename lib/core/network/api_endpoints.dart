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
  static const String latestPortfolio = '/api/portfolio/latest/';
  static const String portfolioHistory = '/api/portfolio/history/';
  static const String portfolioSimulate = '/api/portfolio/simulate/';

  // ── Market ─────────────────────────────────────────────
  static String assetDetail(String ticker) => '/api/market/asset/$ticker/';

  // ── Goals ──────────────────────────────────────────────
  static const String goals = '/api/goals/';
  static String goalDetail(String id) => '/api/goals/$id/';

  // ── Watchlist ──────────────────────────────────────────
  static const String watchlist = '/api/watchlist/';
  static const String watchlistAdd = '/api/watchlist/add/';
  static const String watchlistRemove = '/api/watchlist/remove/';

  // ── News ───────────────────────────────────────────────
  static const String marketNews = '/api/market/news/';

  // ── Drift / Rebalance ─────────────────────────────────
  static const String portfolioDrift = '/api/portfolio/drift/';
}
