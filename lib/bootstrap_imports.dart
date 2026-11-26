// Exposes dependencies used by app bootstrap and AppDependencies assembly.
// Keeps dependency declarations separate from cold-launch orchestration.
export 'dart:ui' show PlatformDispatcher;

export 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, VoidCallback;
export 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthFlowType, FlutterAuthClientOptions, Supabase;

export 'core/env.dart';
export 'core/error/app_crash_logger.dart';
export 'core/lifecycle/session_reset_coordinator.dart';
export 'core/preferences/startup_preferences.dart';
export 'core/supabase/supabase_client_provider.dart';
export 'feature/auth/data/repo/in_memory_auth_repository.dart';
export 'feature/auth/data/repo/supabase_auth_repository.dart';
export 'feature/auth/data/resource/supabase_auth_remote_data_source.dart';
export 'feature/auth/domain/repositories/auth_repository.dart';
export 'feature/community/data/repo/in_memory_community_repository.dart';
export 'feature/community/domain/repositories/community_repository.dart';
export 'feature/home/data/repo/in_memory_home_repository.dart';
export 'feature/home/domain/repositories/home_repository.dart';
export 'feature/practice/data/repo/in_memory_practice_repository.dart';
export 'feature/practice/domain/repositories/practice_repository.dart';
export 'feature/profile/data/repo/in_memory_profile_repository.dart';
export 'feature/profile/domain/entities/app_settings.dart' show AppLanguage;
export 'feature/profile/domain/repositories/profile_repository.dart';
export 'feature/subscription/data/repo/in_memory_subscription_repository.dart';
export 'feature/subscription/domain/repositories/subscription_repository.dart';
