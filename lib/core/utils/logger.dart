import 'dart:developer' as dev;

/// Lightweight structured logger.
///
/// Uses `dart:developer` log() so output appears in the DevTools console
/// with proper severity and is stripped from release builds by tree-shaking
/// when called behind `kDebugMode`.
class AppLogger {
  AppLogger._();

  static const _name = 'Bayesvest';

  static void debug(String message, {String? tag}) {
    dev.log(message, name: tag ?? _name, level: 500);
  }

  static void info(String message, {String? tag}) {
    dev.log(message, name: tag ?? _name, level: 800);
  }

  static void warning(String message, {String? tag}) {
    dev.log('\u26A0\uFE0F $message', name: tag ?? _name, level: 900);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      '\u274C $message',
      name: tag ?? _name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Pretty-print a Map (e.g. request/response bodies).
  static String prettyMap(Map<String, dynamic>? map) {
    if (map == null) return 'null';
    final buf = StringBuffer('{\n');
    for (final entry in map.entries) {
      final val = entry.key.toLowerCase().contains('password') ||
              entry.key.toLowerCase().contains('token') ||
              entry.key.toLowerCase().contains('access') ||
              entry.key.toLowerCase().contains('refresh')
          ? '***'
          : entry.value;
      buf.writeln('  ${entry.key}: $val');
    }
    buf.write('}');
    return buf.toString();
  }
}
