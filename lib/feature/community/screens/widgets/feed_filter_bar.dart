// Filter bar above the feed: horizontally scrolling subject pills.
// Feed sort stays in the cubit's default order; no sort control is shown.
import 'feed_filter_bar_dependencies.dart';

class FeedFilterBar extends StatelessWidget {
  const FeedFilterBar({
    super.key,
    required this.subject,
    required this.onSubject,
  });

  final String subject;
  final ValueChanged<String> onSubject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SubjectPillBar(
          subjects: const [
            CommunitySubjects.all,
            ...CommunitySubjects.selectable,
          ],
          selected: subject,
          onSelected: onSubject,
        ),
      ),
    );
  }
}
