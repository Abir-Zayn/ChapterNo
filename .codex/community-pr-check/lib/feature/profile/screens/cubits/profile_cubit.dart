// Manages loading and updating the student's Profile Dashboard state.
// Guards against stale responses and preserves loaded UI on update failures.
import 'cubits_imports.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._profileRepository})
    : super(const ProfileInitial());

  final ProfileRepository _profileRepository;
  int _loadToken = 0;

  Future<void> load() async {
    final token = ++_loadToken;
    if (state is! ProfileLoaded) {
      emit(const ProfileLoading());
    }
    final result = await _profileRepository.getProfile();
    if (isClosed || token != _loadToken) return;

    result.fold((failure) {
      final current = state;
      if (current is ProfileLoaded) {
        emit(current.copyWith(actionError: failure.message));
      } else {
        emit(ProfileError(failure.message));
      }
    }, (profile) => emit(ProfileLoaded(profile: profile)));
  }

  Future<void> updateLearningPace(String pace) async {
    final current = state;
    if (current is! ProfileLoaded || current.isUpdating) return;

    final token = ++_loadToken;
    emit(current.copyWith(isUpdating: true, clearActionError: true));
    final result = await _profileRepository.updateLearningPace(pace);
    if (isClosed || token != _loadToken) return;

    result.fold(
      (failure) => emit(
        current.copyWith(isUpdating: false, actionError: failure.message),
      ),
      (updated) => emit(ProfileLoaded(profile: updated)),
    );
  }
}
