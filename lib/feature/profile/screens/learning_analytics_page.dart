// Displays Learning Analytics with timeframe filters, KPI metrics, study
// volume chart, subject performance, priority revision, and CQ feedback.
import 'learning_analytics_page_imports.dart';

class LearningAnalyticsPage extends StatelessWidget {
  const LearningAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.title('Learning Analytics'),
        actions: [
          AppIconButton(
            icon: PhosphorIconsRegular.arrowsClockwise,
            tooltip: 'Refresh analytics',
            onPressed: () {
              final state = context.read<LearningAnalyticsCubit>().state;
              final timeframe = state is LearningAnalyticsLoaded
                  ? state.analytics.timeframe
                  : AnalyticsTimeframe.weeks;
              context.read<LearningAnalyticsCubit>().load(timeframe);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<LearningAnalyticsCubit, LearningAnalyticsState>(
          listener: (context, state) {
            if (state is LearningAnalyticsLoaded && state.actionError != null) {
              AppSnackBar.show(
                context,
                state.actionError!,
                type: AppSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              LearningAnalyticsInitial() ||
              LearningAnalyticsLoading() => const AppLoader(),
              LearningAnalyticsError(:final timeframe, :final message) =>
                AppStateView.error(
                  title: 'Could not load analytics',
                  message: message,
                  onAction: () =>
                      context.read<LearningAnalyticsCubit>().load(timeframe),
                ),
              LearningAnalyticsLoaded(:final analytics) => _AnalyticsBody(
                analytics: analytics,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.analytics});

  final LearningAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < AppSizes.narrowBreakpoint
        ? AppSpacing.lg
        : AppSpacing.gutter;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<LearningAnalyticsCubit>().load(analytics.timeframe),
      child: ListView(
        padding: EdgeInsets.all(gutter),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final tf in AnalyticsTimeframe.values) ...[
                  ChoiceChip(
                    label: Text(tf.label),
                    selected: tf == analytics.timeframe,
                    onSelected: (_) => context
                        .read<LearningAnalyticsCubit>()
                        .selectTimeframe(tf),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            color: AppColors.primarySoft,
            borderColor: AppColors.primary,
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.medal,
                  size: AppSizes.iconLg,
                  color: AppColors.primaryPressed,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.title('Weekly Momentum'),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText.caption(
                        analytics.cohortRankLabel,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.fire,
                        size: 16,
                        color: AppColors.primaryPressed,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      AppText.caption(
                        '${analytics.streakDays} Days',
                        color: AppColors.primaryPressed,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileStatGrid(
            items: [
              ProfileStatItem(
                label: 'MCQs Solved',
                value: '${analytics.mcqsSolved}',
                subtitle: analytics.mcqsDeltaLabel,
                icon: PhosphorIconsRegular.checkCircle,
                accentColor: AppColors.success,
                softBackground: AppColors.successSoft,
              ),
              ProfileStatItem(
                label: 'Accuracy',
                value: '${analytics.accuracyPercent}%',
                subtitle: analytics.accuracyDeltaLabel,
                icon: PhosphorIconsRegular.target,
                accentColor: AppColors.info,
                softBackground: AppColors.infoSoft,
              ),
              ProfileStatItem(
                label: 'CQ Practiced',
                value: '${analytics.cqsPracticed}',
                subtitle: '${analytics.cqsEvaluatedCount} evaluated',
                icon: PhosphorIconsRegular.pencilLine,
                accentColor: AppColors.warning,
                softBackground: AppColors.warningSoft,
              ),
              ProfileStatItem(
                label: 'Avg. CQ Score',
                value: '${analytics.avgCqScore}/10',
                subtitle: 'Target: ${analytics.targetCqScore}',
                icon: PhosphorIconsRegular.star,
                accentColor: AppColors.primaryPressed,
                softBackground: AppColors.primarySoft,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AnalyticsStudyChart(
            totalSolvedVolume: analytics.totalSolvedVolume,
            weeklyVolume: analytics.weeklyVolume,
            focusTip: analytics.focusTip,
          ),
          const SizedBox(height: AppSpacing.xl),
          AnalyticsSubjectCard(
            subjects: analytics.subjects,
            totalTopics: analytics.totalTopics,
            strongTopics: analytics.strongTopics,
            inProgressTopics: analytics.inProgressTopics,
            unexploredTopics: analytics.unexploredTopics,
          ),
          const SizedBox(height: AppSpacing.xl),
          AnalyticsRevisionAndCq(
            analytics: analytics,
            onTopicTap: (topic) => AppSnackBar.show(
              context,
              'Practice for "${topic.topicTitle}" will open soon.',
            ),
            onStartPracticeTap: () => AppSnackBar.show(
              context,
              'Adaptive practice session will open soon.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
