// Exposes test utilities, stream controllers, and Supabase auth types for
// testing SessionResetCoordinator isolation and subscription cleanup.
export 'dart:async' show StreamController;

export 'package:chapter_no/core/error/app_crash_logger.dart';
export 'package:chapter_no/core/lifecycle/session_reset_coordinator.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, Session, User;
