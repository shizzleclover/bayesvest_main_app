import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../model/asset_detail.dart';

final assetDetailServiceProvider = Provider<AssetDetailService>((ref) {
  return AssetDetailService(ref.read(dioProvider));
});

class AssetDetailService {
  AssetDetailService(this._dio);
  final Dio _dio;
  static const _tag = 'AssetDetailSvc';

  Future<AssetDetail> getAssetDetail(String ticker) async {
    final url = ApiEndpoints.assetDetail(ticker);
    AppLogger.info('GET $url', tag: _tag);
    final response = await _dio.get(url);
    return AssetDetail.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Family provider keyed by ticker so each asset loads independently.
final assetDetailProvider =
    FutureProvider.family<AssetDetail, String>((ref, ticker) async {
  final service = ref.read(assetDetailServiceProvider);
  return service.getAssetDetail(ticker);
});
