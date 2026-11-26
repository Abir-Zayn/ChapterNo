// Priority revision topics, CQ rubric performance, and next-step CTA cards
// for the Learning Analytics screen.
import 'widgets_imports.dart';

class AnalyticsRevisionAndCq extends StatelessWidget {
  const AnalyticsRevisionAndCq({
    super.key,
    required this.analytics,
    required this.onTopicTap,
    required this.onStartPracticeTap,
  });

  final LearningAnalytics analytics;
  final ValueChanged<PriorityTopic> onTopicTap;
  final VoidCallback onStartPracticeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.title('Priority Revision Needed'),
        const SizedBox(height: AppSpacing.xxs),
        const AppText.caption(
          'High-probability exam topics needing immediate focus',
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < analytics.priorityTopics.length; i++) ...[
                _TopicRow(
                  topic: analytics.priorityTopics[i],
                  onTap: () => onTopicTap(analytics.priorityTopics[i]),
                ),
                if (i < analytics.priorityTopics.length - 1)
                  const Divider(height: 1, thickness: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _CqPerformanceCard(analytics: analytics),
        const SizedBox(height: AppSpacing.lg),
        _NextStepCard(
          analytics: analytics,
          onStartPracticeTap: onStartPracticeTap,
        ),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.onTap});

  final PriorityTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.caption(
                    '${topic.subject} • ${topic.accuracyPercent}% Acc',
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(topic.topicTitle, fontWeight: FontWeight.w600),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: AppText.caption(
                topic.actionTag,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: AppSizes.iconSm,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CqPerformanceCard extends StatelessWidget {
  const _CqPerformanceCard({required this.analytics});

  final LearningAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.title('CQ Written Performance'),
          const SizedBox(height: AppSpacing.xxs),
          const AppText.caption(
            'Diagnostic rubric assessments',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _CqMetric(
                label: 'Practiced',
                value: '${analytics.cqsPracticed} CQs',
              ),
              _CqMetric(
                label: 'Avg. Score',
                value: '${analytics.avgCqScore}/10',
              ),
              _CqMetric(
                label: 'Last Result',
                value: '${analytics.lastCqScore}/10',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIconsRegular.info,
                  size: AppSizes.iconSm,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: AppText.caption(
                    'AI evaluations are diagnostic estimates based on official SSC Board grading rubrics.',
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CqMetric extends StatelessWidget {
  const _CqMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption(label, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.xxs),
          AppText.title(value),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({
    required this.analytics,
    required this.onStartPracticeTap,
  });

  final LearningAnalytics analytics;
  final VoidCallback onStartPracticeTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: context.primarySoft,
      borderColor: context.primary,
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.caption(
            'Recommended Next Step • ~${analytics.recommendedMinutes} mins',
            color: context.primaryStrong,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText.title(analytics.recommendedTitle),
          const SizedBox(height: AppSpacing.xs),
          AppText.caption(
            analytics.recommendedDescription,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Start Practice',
            icon: PhosphorIconsRegular.arrowRight,
            onPressed: onStartPracticeTap,
          ),
        ],
      ),
    );
  }
}
