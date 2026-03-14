import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/logger.dart';
import '../model/auth_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  AuthService(this._dio);
  final Dio _dio;
  static const _tag = 'AuthService';

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    AppLogger.info('POST ${ApiEndpoints.register}  email=$email', tag: _tag);
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password},
    );
    AppLogger.debug('register response status=${response.statusCode}', tag: _tag);
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    AppLogger.info('POST ${ApiEndpoints.login}  email=$email', tag: _tag);
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    AppLogger.debug('login response status=${response.statusCode}', tag: _tag);
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
