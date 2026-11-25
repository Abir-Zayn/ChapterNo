// Section displaying student mastery and chapter coverage across SSC subjects.
// Highlights progress percentages and counts of topics requiring revision.
import 'home_widgets_imports.dart';

class SubjectMasterySection extends StatelessWidget {
  const SubjectMasterySection({
    super.key,
    required this.subjects,
    required this.onSubjectSelected,
  });

  final List<SubjectProgress> subjects;
  final ValueChanged<SubjectProgress> onSubjectSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: AppText.title(
                'Subject Mastery',
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppText.caption(
              '${subjects.length} Subjects',
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subjects.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return _SubjectCard(
              subject: subject,
              onTap: () => onSubjectSelected(subject),
            );
          },
        ),
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.onTap});

  final SubjectProgress subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText.label(
                  subject.subjectName,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppText.label(
                '${subject.masteryPercentage}%',
                fontWeight: FontWeight.w700,
                color: subject.masteryPercentage >= 75
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: subject.masteryRatio,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSunken,
              valueColor: AlwaysStoppedAnimation<Color>(
                subject.masteryPercentage >= 75
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppText.caption(
                  '${subject.completedChapters} of ${subject.totalChapters} Chapters',
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subject.weakTopicsCount > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppText.caption(
                    '${subject.weakTopicsCount} weak',
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
