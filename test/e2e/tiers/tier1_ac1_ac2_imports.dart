// Exposes core config, theme, test helpers, and fakes for Tier 1 AC-1..AC-2.
// Keeps Tier 1 AC-1..AC-2 dependencies explicit and isolated.
export 'dart:async';

export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/config/theme/app_colors.dart';
export 'package:chapter_no/core/env.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right;
export 'package:flutter/gestures.dart';
export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

export '../support/e2e_fakes.dart';
export '../support/e2e_profile_fake.dart';
export '../support/e2e_test_helpers.dart';
