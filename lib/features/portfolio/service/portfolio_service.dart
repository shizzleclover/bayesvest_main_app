import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/portfolio.dart';

final portfolioServiceProvider = Provider<PortfolioService>((ref) {
  return PortfolioService(ref.read(dioProvider));
});

class PortfolioService {
  PortfolioService(this._dio);
  final Dio _dio;

  Future<Portfolio> generatePortfolio() async {
    final response = await _dio.post(ApiEndpoints.generatePortfolio);
    return Portfolio.fromJson(response.data as Map<String, dynamic>);
  }
}
