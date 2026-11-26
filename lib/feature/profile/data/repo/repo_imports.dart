// Exposes dependencies for Profile data repository implementations.
// Keeps imports separate from repository logic.
export 'dart:async' show TimeoutException;

export 'package:dartz/dartz.dart';

export '../../../../core/error/app_crash_logger.dart';
export '../../../../core/preferences/startup_preferences.dart';
export '../../domain/entities/app_settings.dart';
export '../../domain/entities/learning_analytics.dart';
export '../../domain/entities/onboarding_draft.dart';
export '../../domain/entities/profile_failure.dart';
export '../../domain/entities/student_profile.dart';
export '../../domain/repositories/profile_repository.dart';
export '../resource/profile_remote_data_source.dart';
