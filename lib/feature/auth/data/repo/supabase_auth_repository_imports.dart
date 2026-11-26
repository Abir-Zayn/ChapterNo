// Exposes dependencies used by SupabaseAuthRepository.
// Keeps repository imports separate from AuthRepository implementation logic.
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
export 'package:supabase_flutter/supabase_flutter.dart' show SignOutScope;

export '../../../../core/error/app_crash_logger.dart';
export '../../../../core/lifecycle/session_reset_coordinator.dart';
export '../../domain/entities/auth_failure.dart';
export '../../domain/entities/auth_user.dart';
export '../../domain/entities/sign_up_outcome.dart';
export '../../domain/repositories/auth_repository.dart';
export '../resource/supabase_auth_remote_data_source.dart';
export '../utils/auth_exception_mapper.dart';
