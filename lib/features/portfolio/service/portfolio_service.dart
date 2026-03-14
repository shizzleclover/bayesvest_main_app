import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../model/portfolio.dart';

final portfolioServiceProvider = Provider<PortfolioService>((ref) {
  return PortfolioService(ref.read(dioProvider));
});

class PortfolioService {
  PortfolioService(this._dio);
  final Dio _dio;
  static const _tag = 'PortfolioService';

  Future<Portfolio> generatePortfolio() async {
    AppLogger.info('POST ${ApiEndpoints.generatePortfolio}', tag: _tag);
    final response = await _dio.post(ApiEndpoints.generatePortfolio);
    AppLogger.debug('generatePortfolio status=${response.statusCode}', tag: _tag);
    return Portfolio.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Portfolio?> getLatestPortfolio() async {
    AppLogger.info('GET ${ApiEndpoints.latestPortfolio}', tag: _tag);
    try {
      final response = await _dio.get(ApiEndpoints.latestPortfolio);
      return Portfolio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.info('No existing portfolio found', tag: _tag);
        return null;
      }
      rethrow;
    }
  }
}
