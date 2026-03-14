import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../model/financial_profile.dart';
import '../model/risk_assessment.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.read(dioProvider));
});

class OnboardingService {
  OnboardingService(this._dio);
  final Dio _dio;
  static const _tag = 'OnboardingService';

  // ── Financial Profile ────────────────────────────────────

  Future<FinancialProfile> getProfile() async {
    AppLogger.info('GET ${ApiEndpoints.profile}', tag: _tag);
    final response = await _dio.get(ApiEndpoints.profile);
    return FinancialProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> saveProfile(FinancialProfile profile) async {
    AppLogger.info('POST ${ApiEndpoints.profile}', tag: _tag);
    AppLogger.debug('body: ${profile.toJson()}', tag: _tag);
    await _dio.post(ApiEndpoints.profile, data: profile.toJson());
  }

  // ── Risk Assessment ──────────────────────────────────────

  Future<RiskAssessment> getRiskAssessment() async {
    AppLogger.info('GET ${ApiEndpoints.risk}', tag: _tag);
    final response = await _dio.get(ApiEndpoints.risk);
    return RiskAssessment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RiskSubmitResponse> submitRiskAssessment(
    Map<String, String> answers,
  ) async {
    AppLogger.info('POST ${ApiEndpoints.risk}', tag: _tag);
    AppLogger.debug('body keys: ${answers.keys.toList()}', tag: _tag);
    final response = await _dio.post(
      ApiEndpoints.risk,
      data: {'answers': answers},
    );
    return RiskSubmitResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
