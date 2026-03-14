import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class DriftInfo {
  final double driftPct;
  final bool shouldRebalance;
  final String currentRisk;
  final int portfolioAgeDays;

  const DriftInfo({
    required this.driftPct,
    required this.shouldRebalance,
    required this.currentRisk,
    required this.portfolioAgeDays,
  });

  factory DriftInfo.fromJson(Map<String, dynamic> json) => DriftInfo(
        driftPct: (json['drift_pct'] as num?)?.toDouble() ?? 0,
        shouldRebalance: json['should_rebalance'] as bool? ?? false,
        currentRisk: json['current_risk'] as String? ?? '',
        portfolioAgeDays: (json['portfolio_age_days'] as num?)?.toInt() ?? 0,
      );
}

final driftProvider = FutureProvider<DriftInfo?>((ref) async {
  try {
    final dio = ref.read(dioProvider);
    final response = await dio.get(ApiEndpoints.portfolioDrift);
    return DriftInfo.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
