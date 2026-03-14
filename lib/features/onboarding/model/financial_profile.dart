class FinancialProfile {
  final int? age;
  final double? income;
  final double? savings;
  final String? goals;
  final String? horizon;

  const FinancialProfile({
    this.age,
    this.income,
    this.savings,
    this.goals,
    this.horizon,
  });

  factory FinancialProfile.fromJson(Map<String, dynamic> json) =>
      FinancialProfile(
        age: json['age'] as int?,
        income: (json['income'] as num?)?.toDouble(),
        savings: (json['savings'] as num?)?.toDouble(),
        goals: json['goals'] as String?,
        horizon: json['horizon'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (age != null) 'age': age,
        if (income != null) 'income': income,
        if (savings != null) 'savings': savings,
        if (goals != null) 'goals': goals,
        if (horizon != null) 'horizon': horizon,
      };

  FinancialProfile copyWith({
    int? age,
    double? income,
    double? savings,
    String? goals,
    String? horizon,
  }) =>
      FinancialProfile(
        age: age ?? this.age,
        income: income ?? this.income,
        savings: savings ?? this.savings,
        goals: goals ?? this.goals,
        horizon: horizon ?? this.horizon,
      );
}
