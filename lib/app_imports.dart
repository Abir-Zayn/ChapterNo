// Exposes dependencies used by the root app widget.
// Keeps dependency declarations separate from app composition.
export 'dart:async' show unawaited;

export 'package:flutter/material.dart';
export 'package:go_router/go_router.dart' show GoRouter;

export 'bootstrap.dart' show AppDependencies;
export 'config/router/app_router.dart';
export 'config/router/app_routes.dart';
export 'config/theme/app_theme.dart';
export 'core/error/app_crash_logger.dart';
export 'core/lifecycle/session_reset_coordinator.dart';
export 'feature/auth/domain/repositories/auth_repository.dart';
export 'feature/community/domain/repositories/community_repository.dart';
export 'feature/home/domain/repositories/home_repository.dart';
export 'feature/practice/domain/repositories/practice_repository.dart';
export 'feature/profile/domain/repositories/profile_repository.dart';
export 'feature/subscription/domain/repositories/subscription_repository.dart';
