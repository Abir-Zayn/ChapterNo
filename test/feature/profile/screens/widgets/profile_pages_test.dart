// Widget tests for ProfilePage, LearningAnalyticsPage, and SettingsPage.
// Covers rendered states, interactions, error retry, and narrow 1.5x layout.
import 'package:chapter_no/feature/auth/data/repo/in_memory_auth_repository.dart';
import 'package:chapter_no/feature/profile/data/repo/in_memory_profile_repository.dart';
import 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
import 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
import 'package:chapter_no/feature/profile/screens/cubits/learning_analytics_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/profile_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/settings_cubit.dart';
import 'package:chapter_no/feature/profile/screens/learning_analytics_page.dart';
import 'package:chapter_no/feature/profile/screens/profile_page.dart';
import 'package:chapter_no/feature/profile/screens/settings_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late InMemoryProfileRepository repo;
  late InMemoryAuthRepository authRepo;

  setUp(() {
    repo = InMemoryProfileRepository(latency: Duration.zero);
    authRepo = InMemoryAuthRepository(latency: Duration.zero);
  });

  group('ProfilePage', () {
    testWidgets('renders dashboard and triggers analytics/settings callbacks', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 900);
      addTearDown(tester.view.reset);

      var openedAnalytics = false;
      var openedSettings = false;

      await tester.pumpApp(
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: repo)..load(),
          child: ProfilePage(
            onOpenAnalytics: () => openedAnalytics = true,
            onOpenSettings: () => openedSettings = true,
            onOpenSubscription: () {},
            onSignOut: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi, Tanvir!'), findsOneWidget);
      expect(find.text('MCQs Solved'), findsOneWidget);
      expect(find.text('248'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Learning Analytics'));
      expect(openedAnalytics, isTrue);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('App Settings & Language'));
      expect(openedSettings, isTrue);
    });

    testWidgets('shows error state and retries when load fails', (
      tester,
    ) async {
      final mockRepo = _MockProfileRepository();
      var calls = 0;
      when(mockRepo.getProfile).thenAnswer((_) async {
        calls++;
        if (calls == 1) return const Left(ProfileFailure('Server unavailable'));
        return repo.getProfile();
      });

      await tester.pumpApp(
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: mockRepo)..load(),
          child: ProfilePage(
            onOpenAnalytics: () {},
            onOpenSettings: () {},
            onOpenSubscription: () {},
            onSignOut: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load profile'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Hi, Tanvir!'), findsOneWidget);
    });

    testWidgets('renders without overflow on 320dp width at 1.5x text scale', (
      tester,
    ) async {
      await tester.pumpApp(
        BlocProvider(
          create: (_) => ProfileCubit(profileRepository: repo)..load(),
          child: ProfilePage(
            onOpenAnalytics: () {},
            onOpenSettings: () {},
            onOpenSubscription: () {},
            onSignOut: () async {},
          ),
        ),
        width: 320,
        textScale: 1.5,
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi, Tanvir!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('LearningAnalyticsPage', () {
    testWidgets('switches timeframe chip and updates metrics', (tester) async {
      await tester.pumpApp(
        BlocProvider(
          create: (_) =>
              LearningAnalyticsCubit(profileRepository: repo)..load(),
          child: LearningAnalyticsPage(onNavigateToPractice: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weekly Momentum'), findsOneWidget);
      expect(find.text('248'), findsOneWidget);

      await tester.tap(find.text('Months'));
      await tester.pumpAndSettle();

      expect(find.text('${248 * 4}'), findsOneWidget);
    });
  });

  group('SettingsPage', () {
    testWidgets('toggles notification switch and confirms sign-out', (
      tester,
    ) async {
      var signedOut = false;

      await tester.pumpApp(
        BlocProvider(
          create: (_) =>
              SettingsCubit(profileRepository: repo, authRepository: authRepo)
                ..load(),
          child: SettingsPage(
            onOpenPrivacy: () {},
            onOpenSubscription: () {},
            onSignedOut: () => signedOut = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tanvir Ahmed'), findsOneWidget);

      final switchFinder = find.byType(Switch).first;
      expect(tester.widget<Switch>(switchFinder).value, isTrue);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(switchFinder).value, isFalse);

      await tester.scrollUntilVisible(find.text('Log Out'), 300);
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Log out of ChapterNo?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Log Out'));
      await tester.pumpAndSettle();

      expect(signedOut, isTrue);
    });
  });
}
