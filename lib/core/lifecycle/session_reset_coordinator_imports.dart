// Exposes async, callback, and auth-state types for session reset coordination.
// Keeps lifecycle isolation independent of feature widgets and UI layers.
export 'dart:async' show FutureOr, StreamSubscription, unawaited;

export 'package:flutter/foundation.dart' show VoidCallback;
export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState;

export '../error/app_crash_logger.dart';
