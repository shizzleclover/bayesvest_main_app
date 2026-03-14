import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../model/financial_profile.dart';
import '../model/risk_assessment.dart';
import '../service/onboarding_service.dart';

// ── Financial Profile ──────────────────────────────────────

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, FinancialProfile?>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<FinancialProfile?> {
  static const _tag = 'ProfileCtrl';

  @override
  Future<FinancialProfile?> build() async {
    AppLogger.info('build() — fetching profile', tag: _tag);
    try {
      final service = ref.read(onboardingServiceProvider);
      final profile = await service.getProfile();
      AppLogger.info('profile loaded: age=${profile.age}', tag: _tag);
      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('profile 404 — first-time user', tag: _tag);
        return null;
      }
      AppLogger.error('profile fetch failed', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> saveProfile(FinancialProfile profile) async {
    AppLogger.info('saveProfile()', tag: _tag);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(onboardingServiceProvider);
      await service.saveProfile(profile);
      AppLogger.info('profile saved', tag: _tag);
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
  static const _tag = 'RiskCtrl';

  @override
  Future<RiskAssessment?> build() async {
    AppLogger.info('build() — fetching risk assessment', tag: _tag);
    try {
      final service = ref.read(onboardingServiceProvider);
      final risk = await service.getRiskAssessment();
      AppLogger.info('risk loaded: score=${risk.riskScore}', tag: _tag);
      return risk;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('risk 404 — not submitted yet', tag: _tag);
        return null;
      }
      AppLogger.error('risk fetch failed', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<RiskSubmitResponse> submitAnswers(
    Map<String, String> answers,
  ) async {
    AppLogger.info('submitAnswers() keys=${answers.keys.toList()}', tag: _tag);
    final service = ref.read(onboardingServiceProvider);
    final result = await service.submitRiskAssessment(answers);
    AppLogger.info('risk submitted: score=${result.computedRiskScore}', tag: _tag);
    ref.invalidateSelf();
    return result;
  }
}
