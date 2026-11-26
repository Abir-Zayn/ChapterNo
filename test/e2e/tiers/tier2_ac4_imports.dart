// Exposes entities, harness routes, and E2E helpers for Tier 2 AC-4 tests.
// Keeps Tier 2 AC-4 dependencies explicit and isolated.
export 'dart:async';

export 'package:chapter_no/feature/profile/domain/entities/onboarding_draft.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:chapter_no/feature/profile/domain/entities/student_profile.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit;
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_harness.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
