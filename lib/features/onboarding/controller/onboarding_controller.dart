import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/financial_profile.dart';
import '../model/risk_assessment.dart';
import '../service/onboarding_service.dart';

// ── Financial Profile ──────────────────────────────────────

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, FinancialProfile?>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<FinancialProfile?> {
  @override
  Future<FinancialProfile?> build() async {
    try {
      final service = ref.read(onboardingServiceProvider);
      return await service.getProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> saveProfile(FinancialProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(onboardingServiceProvider);
      await service.saveProfile(profile);
      return profile;
    });
  }
}

// ── Risk Assessment ────────────────────────────────────────

final riskControllerProvider =
    AsyncNotifierProvider<RiskController, RiskAssessment?>(
  RiskController.new,
);

class RiskController extends AsyncNotifier<RiskAssessment?> {
  @override
  Future<RiskAssessment?> build() async {
    try {
      final service = ref.read(onboardingServiceProvider);
      return await service.getRiskAssessment();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<RiskSubmitResponse> submitAnswers(
    Map<String, String> answers,
  ) async {
    final service = ref.read(onboardingServiceProvider);
    final result = await service.submitRiskAssessment(answers);
    // Refresh cached assessment after submission.
    ref.invalidateSelf();
    return result;
  }
}
