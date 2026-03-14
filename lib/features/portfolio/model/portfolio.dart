import 'asset_reasoning.dart';

/// The full AI-generated portfolio recommendation.
class Portfolio {
  final String userId;
  final String riskSummary;
  final Map<String, double> assetAllocation;
  final double expectedReturn1y;
  final List<AssetReasoning> reasoning;
  final DateTime? createdAt;

  const Portfolio({
    required this.userId,
    required this.riskSummary,
    required this.assetAllocation,
    required this.expectedReturn1y,
    required this.reasoning,
    this.createdAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    final rawAllocation = json['asset_allocation'] as Map<String, dynamic>;
    final rawReasoning = json['reasoning'] as List<dynamic>;

    return Portfolio(
      userId: json['user_id'] as String,
      riskSummary: json['risk_summary'] as String,
      assetAllocation: rawAllocation
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      expectedReturn1y: (json['expected_return_1y'] as num).toDouble(),
      reasoning: rawReasoning
          .map((e) => AssetReasoning.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
