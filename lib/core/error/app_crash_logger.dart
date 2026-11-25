// Records sanitized runtime and startup diagnostics without throwing.
// Logs only operation, stage, and error type/code in debug builds.
import 'app_crash_logger_imports.dart';

class CrashLogEntry {
  const CrashLogEntry({
    required this.operation,
    required this.stage,
    required this.errorType,
    required this.recordedAt,
    this.errorCode,
  });

  final String operation;
  final String stage;
  final String errorType;
  final String? errorCode;
  final DateTime recordedAt;

  String formatSanitizedLine() {
    final codeSuffix = errorCode == null ? '' : ' code=$errorCode';
    return '[$operation] stage=$stage errorType=$errorType$codeSuffix';
  }
}

class AppCrashLogger {
  AppCrashLogger({
    this._debugSink,
    int maxEntries = 50,
    DateTime Function()? now,
  }) : _maxEntries = maxEntries < 1 ? 1 : maxEntries,
       _now = now ?? DateTime.now;

  final void Function(String line)? _debugSink;
  final int _maxEntries;
  final DateTime Function() _now;
  final List<CrashLogEntry> _entries = <CrashLogEntry>[];

  static final RegExp _unsafeChars = RegExp(r'[^a-zA-Z0-9._-]');

  List<CrashLogEntry> get recentEntries => UnmodifiableListView(_entries);

  void recordError({
    required String operation,
    required String stage,
    Object? error,
    String? errorCode,
  }) {
    try {
      final entry = CrashLogEntry(
        operation: _sanitizeToken(operation, fallback: 'unknown_op'),
        stage: _sanitizeToken(stage, fallback: 'unknown_stage'),
        errorType: _sanitizeToken(
          error?.runtimeType.toString(),
          fallback: 'none',
        ),
        errorCode: errorCode == null ? null : _sanitizeNullableToken(errorCode),
        recordedAt: _now().toUtc(),
      );
      if (_entries.length >= _maxEntries) {
        _entries.removeAt(0);
      }
      _entries.add(entry);
      if (kDebugMode) {
        final sink = _debugSink ?? debugPrint;
        sink(entry.formatSanitizedLine());
      }
    } catch (_) {
      // Deliberate: crash logger must never throw into recursive error loops.
    }
  }

  void recordFlutterError(FlutterErrorDetails details) {
    try {
      recordError(
        operation: 'flutter_framework',
        stage: details.library ?? 'render',
        error: details.exception,
      );
    } catch (_) {
      // Deliberate: crash logger must never throw into recursive error loops.
    }
  }

  void clear() {
    try {
      _entries.clear();
    } catch (_) {
      // Deliberate: clearing diagnostics must never throw.
    }
  }

  static String _sanitizeToken(String? raw, {required String fallback}) {
    final cleaned = _sanitizeNullableToken(raw);
    return cleaned ?? fallback;
  }

  static String? _sanitizeNullableToken(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('@') || trimmed.startsWith('eyJ')) {
      return 'redacted';
    }
    final safe = trimmed.replaceAll(_unsafeChars, '_');
    return safe.length > 64 ? safe.substring(0, 64) : safe;
  }
}
