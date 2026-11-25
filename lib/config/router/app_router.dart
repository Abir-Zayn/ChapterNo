// Builds the app's GoRouter: maps paths to pages, scopes each page's Cubit
// to its route, and turns page callbacks into navigation.
// Social sign-in is not wired yet, so those buttons show a notice.
import 'app_router_imports.dart';

GoRouter createAppRouter({
  required AuthRepository authRepository,
  ProfileRepository? profileRepository,
  CommunityRepository? communityRepository,
  HomeRepository? homeRepository,
  PracticeRepository? practiceRepository,
  SubscriptionRepository? subscriptionRepository,
  String initialLocation = AppRoutes.splash,
}) {
  final resolvedProfileRepo = profileRepository ?? InMemoryProfileRepository();
  final resolvedCommunityRepo =
      communityRepository ?? InMemoryCommunityRepository();
  final resolvedHomeRepo = homeRepository ?? InMemoryHomeRepository();
  final resolvedPracticeRepo =
      practiceRepository ?? InMemoryPracticeRepository();
  final resolvedSubscriptionRepo =
      subscriptionRepository ?? InMemorySubscriptionRepository();
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ...rankedQuizRoutes(),
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
            onNavigateToCommunity: () => context.go(AppRoutes.community),
            onOpenProfile: () => context.push(AppRoutes.profile),
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
            onNavigateToCommunity: () => context.go(AppRoutes.community),
            onSignOut: () async {
              await authRepository.signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              ProfileCubit(profileRepository: resolvedProfileRepo)..load(),
          child: ProfilePage(
            onOpenAnalytics: () => context.push(AppRoutes.learningAnalytics),
            onOpenSettings: () => context.push(AppRoutes.settings),
            onOpenSubscription: () => context.push(AppRoutes.subscription),
            onSignOut: () async {
              final result = await authRepository.signOut();
              if (!context.mounted) return;
              result.fold(
                (_) => AppSnackBar.show(
                  context,
                  'Could not sign out. Please try again.',
                  type: AppSnackBarType.error,
                ),
                (_) => context.go(AppRoutes.welcome),
              );
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.learningAnalytics,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              LearningAnalyticsCubit(profileRepository: resolvedProfileRepo)
                ..load(),
          child: const LearningAnalyticsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => BlocProvider(
          create: (_) => SettingsCubit(
            profileRepository: resolvedProfileRepo,
            authRepository: authRepository,
          )..load(),
          child: SettingsPage(
            onOpenPrivacy: () => context.push(AppRoutes.privacy),
            onOpenSubscription: () => context.push(AppRoutes.subscription),
            onSignedOut: () => context.go(AppRoutes.welcome),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              SubscriptionCubit(repository: resolvedSubscriptionRepo)..load(),
          child: SubscriptionPage(
            onClose: () => context.pop(),
            onOpenTerms: () => context.push(AppRoutes.terms),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              CommunityFeedCubit(repository: resolvedCommunityRepo)..load(),
          child: CommunityFeedPage(
            onOpenCreatePost: () => context.push(AppRoutes.communityCreatePost),
            onOpenProfile: () => context.push(AppRoutes.communityProfile),
            onTabSelected: (tab) => switch (tab) {
              HomeNavTab.home => context.go(AppRoutes.home),
              HomeNavTab.practice => context.go(AppRoutes.practice),
              HomeNavTab.profile => context.push(AppRoutes.profile),
              HomeNavTab.community => null,
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.communityCreatePost,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              CreatePostCubit(repository: resolvedCommunityRepo)
                ..loadAttachments(),
          child: CreatePostPage(
            onPublished: () => context.pop(),
            onCancel: () => context.pop(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.communityProfile,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              CommunityProfileCubit(repository: resolvedCommunityRepo)..load(),
          child: CommunityProfilePage(
            onOpenActivityLog: () =>
                context.push(AppRoutes.communityActivityLog),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.communityActivityLog,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              ActivityLogCubit(repository: resolvedCommunityRepo)..load(),
          child: const CommunityActivityLogPage(),
        ),
      ),
    ],
  );
}

void _notAvailable(BuildContext context, String provider) {
  AppSnackBar.show(context, '$provider sign-in is not available yet.');
}
