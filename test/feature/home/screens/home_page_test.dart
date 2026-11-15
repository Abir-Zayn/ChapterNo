// Widget tests for HomePage verifying dashboard section rendering,
// goal advancement, bottom navigation, and accessibility on narrow screens.
import 'package:chapter_no/feature/home/data/repo/in_memory_home_repository.dart';
import 'package:chapter_no/feature/home/screens/cubits/home_cubit.dart';
import 'package:chapter_no/feature/home/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_page.dart';

void main() {
  group('HomePage', () {
    late InMemoryHomeRepository homeRepository;
    late HomeCubit homeCubit;

    setUp(() {
      homeRepository = InMemoryHomeRepository();
      homeCubit = HomeCubit(homeRepository: homeRepository);
    });

    tearDown(() {
      homeCubit.close();
    });

    Widget createTestWidget({VoidCallback? onSignOut}) {
      return BlocProvider.value(
        value: homeCubit..loadDashboard(),
        child: HomePage(onSignOut: onSignOut ?? () {}),
      );
    }

    testWidgets('renders all core dashboard sections and student greeting', (
      tester,
    ) async {
      await tester.pumpPage(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hello, Siam 👋'), findsOneWidget);
      expect(find.text('SSC 2026 • Science Group'), findsOneWidget);
      expect(find.text('DAILY TARGET'), findsOneWidget);
      expect(
        find.text('Physics: Chapter 4: Work, Power & Energy'),
        findsOneWidget,
      );
      expect(find.text('Quick Study'), findsOneWidget);
      expect(find.text('Board MCQs'), findsOneWidget);
      expect(find.text('Mistake Notebook'), findsOneWidget);
      expect(find.text('Subject Mastery'), findsOneWidget);
      expect(find.text('Recent Practice'), findsOneWidget);
    });

    testWidgets(
      'tapping Continue Practice triggers feedback and advances progress',
      (tester) async {
        await tester.pumpPage(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('15/20 Questions'), findsOneWidget);

        await tester.tap(find.text('Continue Practice'));
        await tester.pumpAndSettle();

        expect(find.text('16/20 Questions'), findsOneWidget);
        expect(
          find.textContaining('Resuming Chapter 4: Work, Power & Energy'),
          findsOneWidget,
        );
      },
    );

    testWidgets('bottom navigation switches tab and shows feedback', (
      tester,
    ) async {
      await tester.pumpPage(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('PRACTICE tab is coming soon'),
        findsOneWidget,
      );
    });

    testWidgets('Profile tab opens account sheet with sign out button', (
      tester,
    ) async {
      var signedOut = false;
      await tester.pumpPage(
        createTestWidget(onSignOut: () => signedOut = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Student Account'), findsOneWidget);
      expect(find.text('Signed in as Siam (SSC 2026 Batch)'), findsOneWidget);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(signedOut, isTrue);
    });

    testWidgets(
      'fits a narrow 360dp phone layout with 1.5x text without overflow',
      (tester) async {
        await tester.pumpPage(
          createTestWidget(),
          size: const Size(360, 640),
          textScale: 1.5,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Hello, Siam 👋'), findsOneWidget);
      },
    );
  });
}
