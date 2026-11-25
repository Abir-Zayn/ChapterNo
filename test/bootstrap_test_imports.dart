// Exposes bootstrap, preferences, Supabase client wrapper, and Flutter test
// utilities for verifying cold-launch ordering and error-handler guarantees.
export 'dart:ui' show PlatformDispatcher;

export 'package:chapter_no/app.dart';
export 'package:chapter_no/bootstrap.dart';
export 'package:chapter_no/core/error/app_crash_logger.dart';
export 'package:chapter_no/core/preferences/startup_preferences.dart';
export 'package:chapter_no/core/supabase/supabase_client_provider.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart'
    show AppLanguage;
export 'package:flutter/foundation.dart' show FlutterError;
export 'package:flutter/widgets.dart' show AppLifecycleState;
export 'package:flutter_test/flutter_test.dart';
export 'package:mocktail/mocktail.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthState, GoTrueClient, SupabaseClient;
