import 'package:dio/dio.dart';

import 'logger.dart';

/// Extracts a user-friendly error message from a [DioException].
///
/// Tries `response.data['error']`, then `response.data['detail']`,
/// then `response.data['message']`, then falls back to the status
/// description or a generic string.
String extractApiError(DioException e, {String fallback = 'Something went wrong. Please try again.'}) {
  AppLogger.error(
    'API error on ${e.requestOptions.method} ${e.requestOptions.path}',
    tag: 'ApiError',
    error: e,
  );

  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    // Log full error body for debugging.
    AppLogger.debug('Error body: ${AppLogger.prettyMap(data)}', tag: 'ApiError');

    // Try common Django error keys.
    final msg = data['error'] ?? data['detail'] ?? data['message'];
    if (msg is String && msg.isNotEmpty) return msg;

    // Some DRF responses nest field errors: { "email": ["This field is required."] }
    for (final value in data.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
  }

  if (data is String && data.isNotEmpty) return data;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check your internet.';
    case DioExceptionType.connectionError:
      return 'Could not reach the server. Check your connection.';
    default:
      return fallback;
  }
}
