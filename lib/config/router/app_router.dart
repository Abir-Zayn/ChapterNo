// Builds the app's GoRouter: maps paths to pages, scopes each page's Cubit
// to its route, and turns page callbacks into navigation.
// Social sign-in is not wired yet, so those buttons show a notice.
import 'app_router_imports.dart';

GoRouter createAppRouter({
  required AuthRepository authRepository,
  HomeRepository? homeRepository,
  PracticeRepository? practiceRepository,
  String initialLocation = AppRoutes.splash,
}) {
  final resolvedHomeRepo = homeRepository ?? InMemoryHomeRepository();
  final resolvedPracticeRepo =
      practiceRepository ?? InMemoryPracticeRepository();
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => SplashCubit(authRepository: authRepository)..start(),
          child: SplashPage(
            onSignedOut: () => context.go(AppRoutes.welcome),
            onSignedIn: () => context.go(AppRoutes.home),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => WelcomePage(
          onContinueWithGoogle: () => _notAvailable(context, 'Google'),
          onContinueWithApple: () => _notAvailable(context, 'Apple'),
          onSignUpWithEmail: () => context.push(AppRoutes.signUp),
          onLogIn: () => context.push(AppRoutes.login),
          onOpenTerms: () => context.push(AppRoutes.terms),
          onOpenPrivacy: () => context.push(AppRoutes.privacy),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => LoginCubit(authRepository: authRepository),
          child: LoginPage(
            onLoggedIn: () => context.go(AppRoutes.home),
            onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            onSignUp: () => context.pushReplacement(AppRoutes.signUp),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => BlocProvider(
          create: (_) => SignUpCubit(authRepository: authRepository),
          child: SignUpPage(
            onSignedUp: () => context.go(AppRoutes.home),
            onLogIn: () => context.pushReplacement(AppRoutes.login),
            onOpenTerms: () => context.push(AppRoutes.terms),
            onOpenPrivacy: () => context.push(AppRoutes.privacy),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => ForgotPasswordCubit(authRepository: authRepository),
          child: ForgotPasswordPage(onBackToLogin: () => context.pop()),
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) =>
            const LegalDocumentPage(document: LocalLegalDocuments.terms),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) =>
            const LegalDocumentPage(document: LocalLegalDocuments.privacy),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              HomeCubit(homeRepository: resolvedHomeRepo)..loadDashboard(),
          child: HomePage(
            onNavigateToPractice: () => context.go(AppRoutes.practice),
            onSignOut: () async {
              await authRepository.signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              PracticeCubit(practiceRepository: resolvedPracticeRepo)
                ..loadDashboard(),
          child: PracticePage(
            onNavigateToHome: () => context.go(AppRoutes.home),
            onSignOut: () async {
              await authRepository.signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
          ),
        ),
      ),
    ],
  );
}

void _notAvailable(BuildContext context, String provider) {
  AppSnackBar.show(context, '$provider sign-in is not available yet.');
}
