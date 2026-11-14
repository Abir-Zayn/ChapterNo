// Exposes dependencies used by the root app widget.
// Keeps dependency declarations separate from app composition.
export 'package:flutter/material.dart';
export 'package:go_router/go_router.dart' show GoRouter;

export 'config/router/app_router.dart';
export 'config/theme/app_theme.dart';
export 'feature/auth/domain/repositories/auth_repository.dart';
export 'feature/home/domain/repositories/home_repository.dart';
