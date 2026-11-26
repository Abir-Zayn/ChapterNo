// Exposes dependencies for Profile feature Cubits and their state classes.
// Keeps dependency declarations separate from Cubit logic.
export 'package:dartz/dartz.dart' show Either, Unit;
export 'package:equatable/equatable.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

export '../../../auth/domain/repositories/auth_repository.dart';
export '../../domain/entities/app_settings.dart';
export '../../domain/entities/learning_analytics.dart';
export '../../domain/entities/onboarding_draft.dart';
export '../../domain/entities/student_profile.dart';
export '../../domain/repositories/profile_repository.dart';
