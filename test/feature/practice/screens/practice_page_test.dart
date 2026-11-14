// Widget tests for PracticePage verifying Stitch practice design elements,
// recent quiz interaction, bottom navigation, and narrow screen responsiveness.
import 'package:chapter_no/feature/practice/data/repo/in_memory_practice_repository.dart';
import 'package:chapter_no/feature/practice/screens/cubits/practice_cubit.dart';
import 'package:chapter_no/feature/practice/screens/practice_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_page.dart';

void main() {
  group('PracticePage', () {
    late InMemoryPracticeRepository repository;
    late PracticeCubit practiceCubit;

    setUp(() {
      repository = InMemoryPracticeRepository();
      practiceCubit = PracticeCubit(practiceRepository: repository);
    });

    tearDown(() {
      practiceCubit.close();
    });

    Widget createTestWidget({
      VoidCallback? onNavigateToHome,
      VoidCallback? onSignOut,
    }) {
      return BlocProvider.value(
        value: practiceCubit..loadDashboard(),
        child: PracticePage(
          onNavigateToHome: onNavigateToHome ?? () {},
          onSignOut: onSignOut ?? () {},
        ),
      );
    }

    testWidgets('renders all core practice sections and Stitch headers', (
      tester,
    ) async {
      await tester.pumpPage(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Practice'), findsWidgets);
      expect(find.text('Keep practicing. Keep improving.'), findsOneWidget);
      expect(find.text('Your Practice Overview'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('MCQs Solved'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('+4%'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Quizzes'), findsOneWidget);

      expect(find.text('Recent Quiz Activity'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('Physics — Motion'), findsOneWidget);
      expect(find.text('Review Results'), findsOneWidget);
      expect(find.text('Biology — Cell Division'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);

      expect(find.text('Start a Practice'), findsOneWidget);
      expect(find.text('Topic MCQ'), findsOneWidget);
      expect(find.text('Board MCQ'), findsOneWidget);
      expect(find.text('CQ Practice'), findsOneWidget);
      expect(find.text('Ranked Quiz'), findsOneWidget);
      expect(find.text('Timed'), findsOneWidget);

      expect(find.text('Daily streak active!'), findsOneWidget);
    });

    testWidgets(
      'tapping Resume on in-progress quiz triggers resumption and snackbar',
      (tester) async {
        await tester.pumpPage(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Question 6 of 20'), findsOneWidget);

        await tester.tap(find.text('Resume'));
        await tester.pumpAndSettle();

        expect(find.text('Question 7 of 20'), findsOneWidget);
        expect(find.textContaining('Resuming Biology'), findsOneWidget);
      },
    );

    testWidgets('bottom navigation Home tab navigates back to Home', (
      tester,
    ) async {
      var navigatedToHome = false;
      await tester.pumpPage(
        createTestWidget(onNavigateToHome: () => navigatedToHome = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(navigatedToHome, isTrue);
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
        expect(find.text('Your Practice Overview'), findsOneWidget);
      },
    );
  });
}
