// Exposes routes, curriculum models, settings, and E2E helpers for Tier 3 part 1.
// Keeps Tier 3 part 1 dependencies explicit and isolated.
export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_curriculum_fake.dart';
export '../support/e2e_curriculum_models.dart';
export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
