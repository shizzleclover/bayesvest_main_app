import 'dart:convert';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import '../utils/logger.dart';

/// Injects the JWT access token into every outgoing request and
/// clears stored tokens on a 401 (forcing re-authentication).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenStorage.clearTokens();
    }
    handler.next(err);
  }
}

/// Logs every HTTP request and response in a readable format.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'HTTP';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('─── REQUEST ───────────────────────────────')
      ..writeln('${options.method}  ${options.uri}')
      ..writeln('Headers: ${_sanitiseHeaders(options.headers)}');

    if (options.data != null) {
      buf.writeln('Body: ${_formatBody(options.data)}');
    }

    AppLogger.info(buf.toString(), tag: _tag);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('─── RESPONSE ${response.statusCode} ──────────────────────')
      ..writeln('${response.requestOptions.method}  ${response.requestOptions.uri}')
      ..writeln('Body: ${_formatBody(response.data)}');

    AppLogger.info(buf.toString(), tag: _tag);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buf = StringBuffer()
      ..writeln('─── ERROR ${err.response?.statusCode ?? "?"} ─────────────────────────')
      ..writeln('${err.requestOptions.method}  ${err.requestOptions.uri}')
      ..writeln('Type: ${err.type}')
      ..writeln('Message: ${err.message}');

    if (err.response?.data != null) {
      buf.writeln('Response body: ${_formatBody(err.response!.data)}');
    }

    AppLogger.error(buf.toString(), tag: _tag, error: err);
    handler.next(err);
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';
    if (data is Map<String, dynamic>) return AppLogger.prettyMap(data);
    if (data is Map) {
      return AppLogger.prettyMap(
          data.map((k, v) => MapEntry(k.toString(), v)));
    }
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return AppLogger.prettyMap(
              decoded.map((k, v) => MapEntry(k.toString(), v)));
        }
        return decoded.toString();
      }
    } catch (_) {
      // Not JSON — fall through.
    }
    final s = data.toString();
    return s.length > 500 ? '${s.substring(0, 500)}…' : s;
  }

  Map<String, dynamic> _sanitiseHeaders(Map<String, dynamic> headers) {
    return headers.map((k, v) {
      if (k.toLowerCase() == 'authorization') return MapEntry(k, 'Bearer ***');
      return MapEntry(k, v);
    });
  }
}
