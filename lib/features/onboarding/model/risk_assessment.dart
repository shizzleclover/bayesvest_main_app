class RiskAssessment {
  final Map<String, String> answers;
  final double riskScore;
  final String? riskLevel;
  final DateTime? createdAt;

  const RiskAssessment({
    required this.answers,
    required this.riskScore,
    this.riskLevel,
    this.createdAt,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      RiskAssessment(
        answers: Map<String, String>.from(json['answers'] as Map),
        riskScore: (json['risk_score'] as num).toDouble(),
        riskLevel: json['risk_level'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

/// Response from `POST /api/users/risk/`.
class RiskSubmitResponse {
  final String status;
  final double computedRiskScore;

  const RiskSubmitResponse({
    required this.status,
    required this.computedRiskScore,
  });

  factory RiskSubmitResponse.fromJson(Map<String, dynamic> json) =>
      RiskSubmitResponse(
        status: json['status'] as String,
        computedRiskScore: (json['computed_risk_score'] as num).toDouble(),
      );
}
