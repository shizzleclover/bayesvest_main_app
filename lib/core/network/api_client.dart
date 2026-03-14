import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';
import 'api_interceptor.dart';

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);

  final baseUrl = ApiEndpoints.baseUrl;
  AppLogger.info(
    'Dio init  baseUrl="$baseUrl"  '
    '(empty=${baseUrl.isEmpty})',
    tag: 'Network',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }
  dio.interceptors.add(AuthInterceptor(tokenStorage));

  return dio;
});
