// Maps Supabase Auth, socket, and timeout exceptions to domain AuthFailure.
// Never forwards raw server messages, emails, or tokens into UI or crash logs.
import 'auth_exception_mapper_imports.dart';

abstract final class AuthExceptionMapper {
  static AuthFailure map(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return AuthFailure.network;
    }
    if (error is AuthWeakPasswordException) {
      return AuthFailure.weakPassword;
    }
    if (error is AuthRetryableFetchException) {
      final status = int.tryParse(error.statusCode ?? '');
      if (status != null && status >= 500) {
        return AuthFailure.unavailable;
      }
      return AuthFailure.network;
    }
    if (error is AuthException) {
      return _mapAuthException(error);
    }
    final typeName = error.runtimeType.toString().toLowerCase();
    if (typeName.contains('clientexception')) {
      return AuthFailure.network;
    }
    return AuthFailure.unknown;
  }

  static bool isNetworkOrOffline(Object error) {
    if (error is SocketException || error is TimeoutException) {
      return true;
    }
    if (error is AuthRetryableFetchException) {
      final status = int.tryParse(error.statusCode ?? '');
      return status == null || status < 500;
    }
    if (error is AuthException) {
      return _mapAuthException(error) == AuthFailure.network;
    }
    return error.runtimeType.toString().toLowerCase().contains(
      'clientexception',
    );
  }

  static String? safeErrorCode(Object error) {
    if (error is AuthException) {
      final code = error.code?.trim();
      if (code != null && code.isNotEmpty) return code;
      final status = error.statusCode?.trim();
      if (status != null && status.isNotEmpty) return status;
    }
    return null;
  }

  static AuthFailure _mapAuthException(AuthException error) {
    final code = error.code?.trim().toLowerCase();
    if (code != null && code.isNotEmpty) {
      final mappedByCode = _fromCode(code);
      if (mappedByCode != null) return mappedByCode;
    }

    final status = int.tryParse(error.statusCode?.trim() ?? '');
    if (status == 429) return AuthFailure.rateLimited;
    if (status == 408) return AuthFailure.network;
    if (status != null && status >= 500) return AuthFailure.unavailable;

    if (error is AuthSessionMissingException) {
      return AuthFailure.invalidCredentials;
    }

    return _fromMessage(error.message.toLowerCase());
  }

  static AuthFailure? _fromCode(String code) => switch (code) {
    'email_not_confirmed' => AuthFailure.emailNotConfirmed,
    'user_already_exists' || 'email_exists' => AuthFailure.emailAlreadyInUse,
    'weak_password' => AuthFailure.weakPassword,
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' ||
    'over_sms_send_rate_limit' => AuthFailure.rateLimited,
    'invalid_credentials' ||
    'invalid_grant' ||
    'user_not_found' ||
    'bad_jwt' ||
    'invalid_jwt' => AuthFailure.invalidCredentials,
    'signup_disabled' ||
    'email_provider_disabled' ||
    'provider_disabled' => AuthFailure.unavailable,
    'request_timeout' ||
    'hook_timeout' ||
    'hook_timeout_after_retry' => AuthFailure.network,
    _ => null,
  };

  static AuthFailure _fromMessage(String message) {
    if (message.contains('email not confirmed')) {
      return AuthFailure.emailNotConfirmed;
    }
    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('already been registered')) {
      return AuthFailure.emailAlreadyInUse;
    }
    if (message.contains('weak password') ||
        message.contains('password should be at least')) {
      return AuthFailure.weakPassword;
    }
    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains(
          'security purposes, you can only request this after',
        )) {
      return AuthFailure.rateLimited;
    }
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        message.contains('wrong password')) {
      return AuthFailure.invalidCredentials;
    }
    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('network')) {
      return AuthFailure.network;
    }
    return AuthFailure.unknown;
  }
}
