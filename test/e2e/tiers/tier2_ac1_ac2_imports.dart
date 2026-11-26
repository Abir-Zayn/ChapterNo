// Exposes auth validators, theme, env, and test helpers for Tier 2 AC-1..AC-2.
// Keeps Tier 2 AC-1..AC-2 dependencies narrow and explicit.
export 'dart:async';

export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/config/theme/app_theme.dart';
export 'package:chapter_no/core/env.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
export 'package:chapter_no/feature/auth/domain/usecase/auth_validators.dart';
export 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
export 'package:dartz/dartz.dart' show Either, Left;
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
