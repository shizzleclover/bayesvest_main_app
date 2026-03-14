class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final DateTime? deadline;
  final String icon;
  final DateTime? createdAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    this.deadline,
    this.icon = 'savings',
    this.createdAt,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  bool get isOnTrack {
    if (deadline == null || monthlyContribution <= 0) return true;
    final remaining = targetAmount - currentAmount;
    final monthsLeft =
        deadline!.difference(DateTime.now()).inDays / 30.0;
    if (monthsLeft <= 0) return currentAmount >= targetAmount;
    return (monthlyContribution * monthsLeft) >= remaining;
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: (json['target_amount'] as num).toDouble(),
        currentAmount: (json['current_amount'] as num).toDouble(),
        monthlyContribution: (json['monthly_contribution'] as num).toDouble(),
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'] as String)
            : null,
        icon: json['icon'] as String? ?? 'savings',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
