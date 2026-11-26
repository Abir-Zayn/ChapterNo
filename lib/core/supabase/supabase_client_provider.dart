// Thin injectable wrapper around Supabase.instance.client for testability.
// Avoids spreading direct Supabase.instance lookups across features.
import 'supabase_client_provider_imports.dart';

class SupabaseClientProvider {
  const SupabaseClientProvider({
    this._clientOverride,
    this._isInitializedCheck,
  });

  final SupabaseClient? _clientOverride;
  final bool Function()? _isInitializedCheck;

  bool get isAvailable {
    if (_clientOverride != null) return true;
    if (_isInitializedCheck != null) return _isInitializedCheck();
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get clientOrNull {
    if (_clientOverride != null) return _clientOverride;
    if (!isAvailable) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get client {
    final resolved = clientOrNull;
    if (resolved == null) {
      throw StateError('SupabaseClient requested before initialization.');
    }
    return resolved;
  }
}
