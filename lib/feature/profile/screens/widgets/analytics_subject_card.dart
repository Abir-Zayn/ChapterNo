// Subject Performance progress card and Syllabus Breakdown summary.
// Always pairs semantic progress bar colours with explicit accuracy labels.
import 'widgets_imports.dart';

class AnalyticsSubjectCard extends StatelessWidget {
  const AnalyticsSubjectCard({
    super.key,
    required this.subjects,
    required this.totalTopics,
    required this.strongTopics,
    required this.inProgressTopics,
    required this.unexploredTopics,
  });

  final List<SubjectPerformance> subjects;
  final int totalTopics;
  final int strongTopics;
  final int inProgressTopics;
  final int unexploredTopics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: AppText.title('Subject Performance')),
                  AppText.caption(
                    '${subjects.length} Enrolled',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < subjects.length; i++) ...[
                _SubjectRow(subject: subjects[i]),
                if (i < subjects.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: AppText.title('Syllabus Breakdown')),
                  AppText.caption(
                    '$totalTopics Total Topics',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _TopicChip(
                    icon: PhosphorIconsRegular.checkCircle,
                    label: '$strongTopics Strong',
                    fg: AppColors.success,
                    bg: AppColors.successSoft,
                  ),
                  _TopicChip(
                    icon: PhosphorIconsRegular.arrowsClockwise,
                    label: '$inProgressTopics In Progress',
                    fg: AppColors.warning,
                    bg: AppColors.warningSoft,
                  ),
                  _TopicChip(
                    icon: PhosphorIconsRegular.lockSimple,
                    label: '$unexploredTopics Unexplored',
                    fg: AppColors.textSecondary,
                    bg: AppColors.surfaceSunken,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});

  final SubjectPerformance subject;

  @override
  Widget build(BuildContext context) {
    final barColor = subject.accuracyPercent >= 80
        ? AppColors.success
        : subject.accuracyPercent >= 70
        ? AppColors.warning
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(subject.subject, fontWeight: FontWeight.w600),
            ),
            AppText.caption(
              '${subject.solvedCount} Solved • ${subject.accuracyPercent}% Acc.',
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: (subject.accuracyPercent / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.icon,
    required this.label,
    required this.fg,
    required this.bg,
  });

  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: AppSpacing.xs),
          AppText.caption(label, color: fg, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}
