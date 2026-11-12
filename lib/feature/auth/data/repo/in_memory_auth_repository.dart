// Temporary AuthRepository that keeps accounts in memory for this app run.
// Used until Supabase Auth is connected: nothing is persisted or sent to a
// server, and password-reset email is reported as unavailable.
import 'package:dartz/dartz.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({this.latency = const Duration(milliseconds: 600)});

  /// Simulated round trip so loading states are visible during review.
  final Duration latency;

  final Map<String, String> _passwordsByEmail = {};
  AuthUser? _current;

  String _key(String email) => email.trim().toLowerCase();

  @override
  Future<Either<AuthFailure, AuthUser?>> restoreSession() async {
    return Right(_current);
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    final key = _key(email);
    if (_passwordsByEmail[key] != password) {
      return const Left(AuthFailure.invalidCredentials);
    }
    return Right(_current = AuthUser(id: key, email: key));
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signUp({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    await Future<void>.delayed(latency);
    final key = _key(email);
    if (_passwordsByEmail.containsKey(key)) {
      return const Left(AuthFailure.emailAlreadyInUse);
    }
    _passwordsByEmail[key] = password;
    return Right(_current = AuthUser(id: key, email: key));
  }

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordReset({
    required String email,
  }) async {
    await Future<void>.delayed(latency);
    return const Left(AuthFailure.unavailable);
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    _current = null;
    return const Right(unit);
  }
}
