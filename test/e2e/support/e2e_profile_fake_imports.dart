// Exposes profile domain types and FakeAuthRepository for FakeProfileRepository.
// Keeps E2E profile fake dependencies narrow and explicit.
export 'dart:async';

export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:chapter_no/feature/profile/domain/entities/learning_analytics.dart';
export 'package:chapter_no/feature/profile/domain/entities/onboarding_draft.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:chapter_no/feature/profile/domain/entities/student_profile.dart';
export 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;

export 'e2e_fakes.dart';
