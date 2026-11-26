// Exposes domain contracts, async primitives, and test doubles for E2E fakes.
// Keeps E2E fake dependencies explicit and isolated from broken lib files.
export 'dart:async';

export 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
export 'package:chapter_no/feature/auth/domain/entities/sign_up_outcome.dart';
export 'package:chapter_no/feature/auth/domain/repositories/auth_repository.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:chapter_no/feature/profile/domain/entities/learning_analytics.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:chapter_no/feature/profile/domain/entities/student_profile.dart';
export 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
