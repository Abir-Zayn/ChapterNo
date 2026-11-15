// Verifies Community screen loading, form modes, and narrow layouts.
// Uses the actual local repository with zero simulated latency.
import 'community_screens_test_dependencies.dart';

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets('all six Community designs render at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryCommunityRepository(latency: Duration.zero);
      Future<void> show(Widget page) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(width == 320 ? 1.4 : 1)),
              child: child!,
            ),
            home: page,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await show(
        BlocProvider(
          create: (_) => CommunityFeedCubit(repository: repository)..load(),
          child: CommunityFeedPage(
            onOpenCreatePost: () async {},
            onOpenProfile: () {},
          ),
        ),
      );
      expect(find.text('New Post'), findsOneWidget);
      await show(
        BlocProvider(
          create: (_) => CommunityProfileCubit(repository: repository)..load(),
          child: CommunityProfilePage(onOpenActivityLog: () {}),
        ),
      );
      expect(find.text('Alex R.'), findsOneWidget);
      await show(
        BlocProvider(
          create: (_) => ActivityLogCubit(repository: repository)..load(),
          child: const CommunityActivityLogPage(),
        ),
      );
      expect(find.text('Filter'), findsOneWidget);
      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await show(
        BlocProvider(
          create: (_) =>
              CreatePostCubit(repository: repository)..loadAttachments(),
          child: CreatePostPage(onPublished: () {}, onCancel: () {}),
        ),
      );
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Add a title'), findsOneWidget);
      for (final label in ['Practice Question', 'PDF Notes', 'Discussion']) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
