// Widget tests for the ranked quiz UI preview: entry rendering, answer
// selection, forfeit confirmation, finishing, and narrow-screen layout.
import 'package:chapter_no/feature/ranked_quiz/screens/active_ranked_quiz_page.dart';
import 'package:chapter_no/feature/ranked_quiz/screens/daily_attempt_limit_page.dart';
import 'package:chapter_no/feature/ranked_quiz/screens/ranked_quiz_entry_page.dart';
import 'package:chapter_no/feature/ranked_quiz/screens/ranked_quiz_results_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_page.dart';

void main() {
  testWidgets('entry starts the quiz', (tester) async {
    var started = false;
    await tester.pumpPage(
      RankedQuizEntryPage(
        onStart: () => started = true,
        onViewLeaderboard: () {},
      ),
    );
    await tester.scrollUntilVisible(find.text('Start Ranked Quiz'), 200);
    await tester.tap(find.text('Start Ranked Quiz'));
    expect(started, isTrue);
  });

  testWidgets('selecting an option marks it selected', (tester) async {
    await tester.pumpPage(
      ActiveRankedQuizPage(onFinished: () {}, onForfeit: () {}),
    );
    await tester.tap(find.text('25 m/s'));
    await tester.pump();
    final tile = tester.getSemantics(find.bySemanticsLabel('Option B, 25 m/s'));
    expect(tile.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('exit asks before forfeiting', (tester) async {
    var forfeited = false;
    await tester.pumpPage(
      ActiveRankedQuizPage(
        onFinished: () {},
        onForfeit: () => forfeited = true,
      ),
    );
    await tester.tap(find.byTooltip('Exit quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stay & Continue'));
    await tester.pumpAndSettle();
    expect(forfeited, isFalse);

    await tester.tap(find.byTooltip('Exit quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forfeit Attempt'));
    await tester.pumpAndSettle();
    expect(forfeited, isTrue);
  });

  testWidgets('last question submits the quiz', (tester) async {
    var finished = false;
    await tester.pumpPage(
      ActiveRankedQuizPage(onFinished: () => finished = true, onForfeit: () {}),
    );
    for (var i = 0; i < 9; i++) {
      await tester.tap(find.text('Next Question'));
      await tester.pump();
    }
    await tester.tap(find.text('Submit Quiz'));
    expect(finished, isTrue);
  });

  testWidgets('screens fit a narrow phone with large text', (tester) async {
    final pages = <Widget>[
      RankedQuizEntryPage(onStart: () {}, onViewLeaderboard: () {}),
      ActiveRankedQuizPage(onFinished: () {}, onForfeit: () {}),
      RankedQuizResultsPage(
        onClose: () {},
        onReviewAnswers: () {},
        onViewLeaderboard: () {},
        onBackToPractice: () {},
      ),
      DailyAttemptLimitPage(
        onPractice: () {},
        onReviewMistakes: () {},
        onViewLeaderboard: () {},
      ),
    ];
    for (final page in pages) {
      await tester.pumpPage(page, size: const Size(320, 640), textScale: 1.3);
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
