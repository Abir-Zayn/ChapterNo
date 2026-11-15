// Manages Settings loading, preference updates, and safe sign-out.
// Keeps existing settings visible if an update or sign-out fails.
import 'cubits_imports.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this._profileRepository,
    required this._authRepository,
  }) : super(const SettingsInitial());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  int _requestToken = 0;

  Future<void> load() async {
    final token = ++_requestToken;
    emit(const SettingsLoading());

    final profileFuture = _profileRepository.getProfile();
    final settingsFuture = _profileRepository.getSettings();
    final profileResult = await profileFuture;
    final settingsResult = await settingsFuture;
    if (isClosed || token != _requestToken) return;

    profileResult.fold(
      (failure) => emit(SettingsError(failure.message)),
      (profile) => settingsResult.fold(
        (failure) => emit(SettingsError(failure.message)),
        (settings) =>
            emit(SettingsLoaded(profile: profile, settings: settings)),
      ),
    );
  }

  Future<void> updateSettings(AppSettings updated) async {
    final current = state;
    if (current is! SettingsLoaded ||
        current.isSaving ||
        current.isSigningOut) {
      return;
    }

    final token = ++_requestToken;
    emit(
      current.copyWith(
        settings: updated,
        isSaving: true,
        clearActionError: true,
      ),
    );
    final result = await _profileRepository.updateSettings(updated);
    if (isClosed || token != _requestToken) return;

    result.fold(
      (failure) =>
          emit(current.copyWith(isSaving: false, actionError: failure.message)),
      (saved) => emit(
        current.copyWith(
          settings: saved,
          isSaving: false,
          clearActionError: true,
        ),
      ),
    );
  }

  Future<void> signOut() async {
    final current = state;
    if (current is! SettingsLoaded || current.isSigningOut) return;

    emit(current.copyWith(isSigningOut: true, clearActionError: true));
    final result = await _authRepository.signOut();
    if (isClosed) return;

    result.fold(
      (_) => emit(
        current.copyWith(
          isSigningOut: false,
          actionError: 'Could not sign out. Please try again.',
        ),
      ),
      (_) => emit(current.copyWith(isSigningOut: false, signedOut: true)),
    );
  }
}
