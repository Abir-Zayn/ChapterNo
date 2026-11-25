// Deterministic controllable FakeAuthRepository and FakeAppPrefsStore for
// Step 1 opaque-box E2E tests. Enforces real credential verification,
// normalized email keys, UTC ISO DOB formatting, and configurable failures.
import 'e2e_fakes_imports.dart';

class FakeAppPrefsStore {
  bool darkModeEnabled = false;
  AppLanguage language = AppLanguage.english;

  void writeRawCorrupted({required String? rawDarkMode, String? rawLang}) {
    darkModeEnabled = rawDarkMode == 'true';
    language = rawLang == 'bn' ? AppLanguage.bangla : AppLanguage.english;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.prefs});

  final FakeAppPrefsStore? prefs;
  final Map<String, String> _passwords = {};
  final Map<String, AuthUser> _users = {};
  final Map<String, String> dobIsoByEmail = {};
  final List<String> sentResetEmails = [];
  final StreamController<String?> _authUserChanges =
      StreamController<String?>.broadcast();

  AuthUser? currentUser;
  bool nextSignUpRequiresVerification = false;
  final Set<String> unconfirmedEmails = {};

  Completer<Either<AuthFailure, AuthUser?>>? restoreCompleter;
  Completer<Either<AuthFailure, AuthUser>>? signInCompleter;
  Completer<Either<AuthFailure, AuthUser>>? signUpCompleter;
  Completer<Either<AuthFailure, Unit>>? resetCompleter;
  Completer<Either<AuthFailure, Unit>>? signOutCompleter;

  AuthFailure? nextRestoreFailure;
  AuthFailure? nextSignInFailure;
  AuthFailure? nextSignUpFailure;
  AuthFailure? nextResetFailure;
  AuthFailure? nextSignOutFailure;
  bool offlineSignOutClearsLocal = true;

  int restoreCalls = 0;
  int signInCalls = 0;
  int signUpCalls = 0;
  int resetCalls = 0;
  int signOutCalls = 0;

  Stream<String?> get authUserChanges => _authUserChanges.stream;

  void seedUser({
    required String id,
    required String email,
    required String password,
    String dobIso = '2010-05-10',
    bool signedIn = false,
    bool emailConfirmed = true,
  }) {
    final key = _normalize(email);
    final user = AuthUser(id: id, email: key);
    _users[key] = user;
    _passwords[key] = password;
    dobIsoByEmail[key] = dobIso;
    if (!emailConfirmed) {
      unconfirmedEmails.add(key);
    } else {
      unconfirmedEmails.remove(key);
    }
    if (signedIn) {
      currentUser = user;
      _authUserChanges.add(user.id);
    }
  }

  void confirmEmail(String email) =>
      unconfirmedEmails.remove(_normalize(email));

  String _normalize(String email) => email.trim().toLowerCase();

  @override
  Future<Either<AuthFailure, AuthUser?>> restoreSession() async {
    restoreCalls++;
    if (restoreCompleter != null) return restoreCompleter!.future;
    final failure = nextRestoreFailure;
    nextRestoreFailure = null;
    if (failure != null) return Left(failure);
    return Right(currentUser);
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInCompleter != null) return signInCompleter!.future;
    final failure = nextSignInFailure;
    nextSignInFailure = null;
    if (failure != null) return Left(failure);

    final key = _normalize(email);
    if (unconfirmedEmails.contains(key)) {
      return const Left(AuthFailure.invalidCredentials);
    }
    final user = _users[key];
    if (user == null || _passwords[key] != password) {
      return const Left(AuthFailure.invalidCredentials);
    }
    currentUser = user;
    _authUserChanges.add(user.id);
    return Right(user);
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signUp({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    signUpCalls++;
    if (signUpCompleter != null) return signUpCompleter!.future;
    final failure = nextSignUpFailure;
    nextSignUpFailure = null;
    if (failure != null) return Left(failure);

    final key = _normalize(email);
    if (_users.containsKey(key)) {
      return const Left(AuthFailure.emailAlreadyInUse);
    }
    final utcDob = DateTime.utc(
      dateOfBirth.year,
      dateOfBirth.month,
      dateOfBirth.day,
    );
    final mm = utcDob.month.toString().padLeft(2, '0');
    final dd = utcDob.day.toString().padLeft(2, '0');
    dobIsoByEmail[key] = '${utcDob.year}-$mm-$dd';

    final user = AuthUser(id: 'user-${_users.length + 1}', email: key);
    _users[key] = user;
    _passwords[key] = password;
    if (nextSignUpRequiresVerification) {
      unconfirmedEmails.add(key);
      return Right(user);
    }
    currentUser = user;
    _authUserChanges.add(user.id);
    return Right(user);
  }

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordReset({
    required String email,
  }) async {
    resetCalls++;
    if (resetCompleter != null) return resetCompleter!.future;
    final failure = nextResetFailure;
    nextResetFailure = null;
    if (failure != null) return Left(failure);
    sentResetEmails.add(_normalize(email));
    return const Right(unit);
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    signOutCalls++;
    if (signOutCompleter != null) return signOutCompleter!.future;
    final failure = nextSignOutFailure;
    nextSignOutFailure = null;
    if (failure != null) {
      if (offlineSignOutClearsLocal && failure == AuthFailure.network) {
        currentUser = null;
        _authUserChanges.add(null);
        return const Right(unit);
      }
      return Left(failure);
    }
    currentUser = null;
    _authUserChanges.add(null);
    return const Right(unit);
  }

  Future<void> dispose() => _authUserChanges.close();
}
