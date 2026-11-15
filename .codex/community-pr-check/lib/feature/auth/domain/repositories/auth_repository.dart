// Contract for authentication operations used by the auth feature.
// Implemented in the data layer; a Supabase implementation replaces the
// in-memory one without changes to Cubits or screens.
import 'package:dartz/dartz.dart';

import '../entities/auth_failure.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  /// Returns the current user, or null when nobody is signed in.
  Future<Either<AuthFailure, AuthUser?>> restoreSession();

  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthUser>> signUp({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  });

  Future<Either<AuthFailure, Unit>> sendPasswordReset({required String email});

  Future<Either<AuthFailure, Unit>> signOut();
}
