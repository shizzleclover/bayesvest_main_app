import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/savings_goal.dart';

final goalsProvider =
    AsyncNotifierProvider<GoalsController, List<SavingsGoal>>(
  GoalsController.new,
);

class GoalsController extends AsyncNotifier<List<SavingsGoal>> {
  @override
  Future<List<SavingsGoal>> build() async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(ApiEndpoints.goals);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    double currentAmount = 0,
    double monthlyContribution = 0,
    String? deadline,
    String icon = 'savings',
  }) async {
    final dio = ref.read(dioProvider);
    await dio.post(ApiEndpoints.goals, data: {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'monthly_contribution': monthlyContribution,
      if (deadline != null) 'deadline': deadline,
      'icon': icon,
    });
    ref.invalidateSelf();
  }

  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    final dio = ref.read(dioProvider);
    await dio.put(ApiEndpoints.goalDetail(id), data: data);
    ref.invalidateSelf();
  }

  Future<void> deleteGoal(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete(ApiEndpoints.goalDetail(id));
    ref.invalidateSelf();
  }
}
