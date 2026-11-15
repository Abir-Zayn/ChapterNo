// Exposes dependencies used by the app entry point.
// Keeps dependency declarations separate from app bootstrap code.
export 'package:flutter/material.dart' show runApp;

export 'app.dart';
export 'feature/auth/data/repo/in_memory_auth_repository.dart';
export 'feature/profile/data/repo/in_memory_profile_repository.dart';
