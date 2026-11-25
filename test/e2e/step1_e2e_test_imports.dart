// Exposes core config, theme, and E2E helpers for the Step 1 smoke test.
// Keeps step1_e2e_test dependencies narrow and explicit.
export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/config/theme/app_theme.dart';
export 'package:chapter_no/core/env.dart';
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export 'support/e2e_curriculum_fake.dart';
export 'support/e2e_fakes.dart';
export 'support/e2e_profile_fake.dart';
export 'support/e2e_test_helpers.dart';
