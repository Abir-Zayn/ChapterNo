// Decides where the app goes after launch: welcome, onboarding, or home.
// Holds the brand screen briefly, checks the onboarding gate after
// sign-in, and keeps the user signed in with retry when the gate check
// fails transiently.
import 'cubits_imports.dart';

enum SplashStatus {
  checking,
  signedOut,
  needsOnboarding,
  ready,
  profileLoadFailed,
}

class SplashCubit extends Cubit<SplashStatus> {
  SplashCubit({
    required this._authRepository,
    this._profileRepository,
    this.minimumDisplay = const Duration(milliseconds: 900),
  }) : super(SplashStatus.checking);

  final AuthRepository _authRepository;
  final ProfileRepository? _profileRepository;
  final Duration minimumDisplay;

  Future<void> start() => _run();

  /// Re-runs the launch check after a transient profile gate failure.
  Future<void> retry() => _run();

  /// Signs the student out from the profile failure screen; even if the
  /// remote sign-out fails, the local reset keeps the next launch honest.
  Future<void> signOutFromProfileFailure() async {
    await _authRepository.signOut();
    if (isClosed) return;
    emit(SplashStatus.signedOut);
  }

  Future<void> _run() async {
    final allowed =
        state == SplashStatus.checking ||
        state == SplashStatus.profileLoadFailed;
    if (!allowed) return;
    // The cubit is born in checking; re-emitting would duplicate the value
    // on first launch and break state-sequence expectations.
    if (state != SplashStatus.checking) {
      emit(SplashStatus.checking);
    }
    final results = await Future.wait<Object?>([
      _authRepository.restoreSession(),
      Future<void>.delayed(minimumDisplay),
    ]);
    if (isClosed) return;
    final session = results.first! as Either<AuthFailure, AuthUser?>;
    final user = session.fold((_) => null, (user) => user);
    if (user == null) {
      emit(SplashStatus.signedOut);
      return;
    }
    final profileRepository = _profileRepository;
    if (profileRepository == null) {
      // Without a gate source the safe default is the onboarding route.
      emit(SplashStatus.needsOnboarding);
      return;
    }
    final status = await profileRepository.getOnboardingStatus();
    if (isClosed) return;
    status.fold(
      (_) => emit(SplashStatus.profileLoadFailed),
      (completed) =>
          emit(completed ? SplashStatus.ready : SplashStatus.needsOnboarding),
    );
  }
}
