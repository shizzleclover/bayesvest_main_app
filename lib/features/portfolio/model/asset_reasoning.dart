/// A single asset's allocation details and plain-English explanation.
class AssetReasoning {
  final String ticker;
  final String assetName;
  final double allocationPct;
  final double expectedReturn;
  final double volatility;
  final double suitabilityScore;
  final String explanation;

  const AssetReasoning({
    required this.ticker,
    required this.assetName,
    required this.allocationPct,
    required this.expectedReturn,
    required this.volatility,
    required this.suitabilityScore,
    required this.explanation,
  });

  factory AssetReasoning.fromJson(Map<String, dynamic> json) =>
      AssetReasoning(
        ticker: json['ticker'] as String,
        assetName: json['asset_name'] as String,
        allocationPct: (json['allocation_pct'] as num).toDouble(),
        expectedReturn: (json['expected_return'] as num).toDouble(),
        volatility: (json['volatility'] as num).toDouble(),
        suitabilityScore: (json['suitability_score'] as num).toDouble(),
        explanation: json['explanation'] as String,
      );
}
