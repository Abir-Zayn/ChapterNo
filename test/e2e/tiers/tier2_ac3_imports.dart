// Exposes cubits, routes, failures, and E2E helpers for Tier 2 AC-3 tests.
// Keeps Tier 2 AC-3 dependencies explicit and isolated.
export 'dart:async';

export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
export 'package:chapter_no/feature/auth/screens/cubits/splash_cubit.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:dartz/dartz.dart' show Either, Right;
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
