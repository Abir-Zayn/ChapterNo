// Exposes dependencies shared by Supabase auth data-layer tests.
// Keeps mock, SDK, and domain imports separate from test specifications.
export 'dart:async' show TimeoutException;
export 'dart:io' show SocketException;

export 'package:chapter_no/core/error/app_crash_logger.dart';
export 'package:chapter_no/core/lifecycle/session_reset_coordinator.dart';
export 'package:chapter_no/feature/auth/data/repo/supabase_auth_repository.dart';
export 'package:chapter_no/feature/auth/data/resource/supabase_auth_remote_data_source.dart';
export 'package:chapter_no/feature/auth/data/utils/auth_exception_mapper.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
export 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
export 'package:chapter_no/feature/auth/domain/entities/sign_up_outcome.dart';
export 'package:dartz/dartz.dart' show Left, Right, Unit, unit;
export 'package:flutter_test/flutter_test.dart';
export 'package:mocktail/mocktail.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthApiException,
        AuthException,
        AuthResponse,
        AuthRetryableFetchException,
        AuthSessionMissingException,
        AuthWeakPasswordException,
        GoTrueClient,
        Session,
        SignOutScope,
        User;
