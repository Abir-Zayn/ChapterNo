// Exposes dependencies used by AuthExceptionMapper.
// Keeps exception and domain failure imports separate from mapping rules.
export 'dart:async' show TimeoutException;
export 'dart:io' show SocketException;

export 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthException,
        AuthRetryableFetchException,
        AuthSessionMissingException,
        AuthWeakPasswordException;

export '../../domain/entities/auth_failure.dart';
