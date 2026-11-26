// Exposes dependencies for the SupabaseProfileRepository test.
// Keeps dependency declarations separate from repository behavior checks.
export 'dart:async' show Completer, TimeoutException;

export 'package:chapter_no/core/error/app_crash_logger.dart';
export 'package:chapter_no/core/preferences/startup_preferences.dart';
export 'package:chapter_no/feature/profile/data/repo/supabase_profile_repository.dart';
export 'package:chapter_no/feature/profile/data/resource/profile_remote_data_source.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:chapter_no/feature/profile/domain/entities/learning_analytics.dart';
export 'package:chapter_no/feature/profile/domain/entities/onboarding_draft.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:chapter_no/feature/profile/domain/entities/student_profile.dart';
export 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
export 'package:flutter_test/flutter_test.dart';
export 'package:mocktail/mocktail.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
