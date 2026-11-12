// Decides where the app goes after launch: signed-in home or welcome.
// Holds the brand screen for a short minimum time so it does not flash,
// and treats a failed session check as signed out.
import 'cubits_imports.dart';

enum SplashStatus { checking, signedOut, signedIn }

class SplashCubit extends Cubit<SplashStatus> {
  SplashCubit({
    required this._authRepository,
    this.minimumDisplay = const Duration(milliseconds: 900),
  }) : super(SplashStatus.checking);

  final AuthRepository _authRepository;
  final Duration minimumDisplay;

  Future<void> start() async {
    if (state != SplashStatus.checking) return;
    final results = await Future.wait<Object?>([
      _authRepository.restoreSession(),
      Future<void>.delayed(minimumDisplay),
    ]);
    if (isClosed) return;
    final session = results.first! as Either<AuthFailure, AuthUser?>;
    final user = session.fold((_) => null, (user) => user);
    emit(user == null ? SplashStatus.signedOut : SplashStatus.signedIn);
  }
}
