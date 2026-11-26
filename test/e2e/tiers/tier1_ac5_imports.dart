// Exposes routes, settings entities, and fakes for Tier 1 AC-5 tests.
// Keeps Tier 1 AC-5 dependencies explicit and separate.
export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
