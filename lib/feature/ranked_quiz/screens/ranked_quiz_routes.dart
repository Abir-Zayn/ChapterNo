// GoRouter routes for the ranked quiz UI preview.
// Callbacks only navigate; unbuilt destinations show a "not available" notice.
import 'ranked_quiz_routes_imports.dart';

List<GoRoute> rankedQuizRoutes() => [
  GoRoute(
    path: AppRoutes.rankedQuiz,
    builder: (context, state) => RankedQuizEntryPage(
      onStart: () => context.push(
        RankedQuizFixtures.attemptsUsed >= RankedQuizFixtures.dailyLimit
            ? AppRoutes.rankedQuizLimit
            : AppRoutes.rankedQuizPlay,
      ),
      onViewLeaderboard: () => _comingSoon(context, 'Leaderboard'),
    ),
  ),
  GoRoute(
    path: AppRoutes.rankedQuizPlay,
    builder: (context, state) => ActiveRankedQuizPage(
      onFinished: () => context.pushReplacement(AppRoutes.rankedQuizResults),
      onForfeit: () => context.pop(),
    ),
  ),
  GoRoute(
    path: AppRoutes.rankedQuizResults,
    builder: (context, state) => RankedQuizResultsPage(
      onClose: () => context.pop(),
      onReviewAnswers: () => _comingSoon(context, 'Answer review'),
      onViewLeaderboard: () => _comingSoon(context, 'Leaderboard'),
      onBackToPractice: () => context.go(AppRoutes.home),
      onShare: () => _comingSoon(context, 'Sharing'),
    ),
  ),
  GoRoute(
    path: AppRoutes.rankedQuizLimit,
    builder: (context, state) => DailyAttemptLimitPage(
      onPractice: () => _comingSoon(context, 'Practice Hub'),
      onReviewMistakes: () => _comingSoon(context, 'Mistake review'),
      onViewLeaderboard: () => _comingSoon(context, 'Leaderboard'),
    ),
  ),
];

void _comingSoon(BuildContext context, String feature) {
  AppSnackBar.show(context, '$feature is not available yet.');
}
