// Root widget: owns the router and applies the ChapterNo theme.
// Receives its repositories from the entry point so tests and future
// backends can supply their own implementations.
import 'app_imports.dart';

class ChapterNoApp extends StatefulWidget {
  const ChapterNoApp({
    super.key,
    required this.authRepository,
    this.profileRepository,
    this.communityRepository,
    this.homeRepository,
    this.practiceRepository,
  });

  final AuthRepository authRepository;
  final ProfileRepository? profileRepository;
  final CommunityRepository? communityRepository;
  final HomeRepository? homeRepository;
  final PracticeRepository? practiceRepository;

  @override
  State<ChapterNoApp> createState() => _ChapterNoAppState();
}

class _ChapterNoAppState extends State<ChapterNoApp> {
  late final GoRouter _router = createAppRouter(
    authRepository: widget.authRepository,
    profileRepository: widget.profileRepository,
    communityRepository: widget.communityRepository,
    homeRepository: widget.homeRepository,
    practiceRepository: widget.practiceRepository,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChapterNo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
