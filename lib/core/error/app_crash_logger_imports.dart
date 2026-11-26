// Exposes dependencies for the sanitized non-throwing crash logger.
// Keeps foundation diagnostics isolated from the rest of the app.
export 'dart:collection' show UnmodifiableListView;

export 'package:flutter/foundation.dart'
    show FlutterErrorDetails, debugPrint, kDebugMode;
