// Exposes profile cubits, entities, routes, and E2E helpers for Tier 2 AC-5.
// Keeps Tier 2 AC-5 dependencies narrow and explicit.
export 'dart:async';

export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/feature/profile/domain/entities/learning_analytics.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:chapter_no/feature/profile/domain/entities/student_profile.dart';
export 'package:chapter_no/feature/profile/screens/cubits/profile_cubit.dart';
export 'package:chapter_no/feature/profile/screens/cubits/profile_state.dart';
export 'package:dartz/dartz.dart' show Either, Right;
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
