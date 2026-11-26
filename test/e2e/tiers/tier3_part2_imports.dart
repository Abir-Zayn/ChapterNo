// Exposes routes, settings, failures, and E2E helpers for Tier 3 part 2.
// Keeps Tier 3 part 2 dependencies explicit and isolated.
export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_curriculum_fake.dart';
export '../support/e2e_curriculum_models.dart';
export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
