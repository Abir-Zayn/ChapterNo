// Bottom sheet for filtering the activity log by category. Counts come from
// the loaded entries. Selection is local until the student taps Apply.
import 'community_widgets_imports.dart';

Future<void> showActivityFilterSheet(
  BuildContext context, {
  required ActivityFilter current,
  required Map<ActivityFilter, int> counts,
  required ValueChanged<ActivityFilter> onApply,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (sheetContext) => _ActivityFilterSheetBody(
      current: current,
      counts: counts,
      onApply: (filter) {
        Navigator.of(sheetContext).pop();
        onApply(filter);
      },
    ),
  );
}

class _ActivityFilterSheetBody extends StatefulWidget {
  const _ActivityFilterSheetBody({
    required this.current,
    required this.counts,
    required this.onApply,
  });

  final ActivityFilter current;
  final Map<ActivityFilter, int> counts;

  /// Receives the confirmed filter after the sheet closes.
  final ValueChanged<ActivityFilter> onApply;

  @override
  State<_ActivityFilterSheetBody> createState() =>
      _ActivityFilterSheetBodyState();
}

class _ActivityFilterSheetBodyState extends State<_ActivityFilterSheetBody> {
  late ActivityFilter _selected = widget.current;

  static const List<(ActivityFilter, String, String, IconData)> _options = [
    (
      ActivityFilter.all,
      'All Activity',
      "Everything you've done",
      PhosphorIconsRegular.infinity,
    ),
    (
      ActivityFilter.posts,
      'Posts Published',
      'Questions & discussions started',
      PhosphorIconsRegular.fileText,
    ),
    (
      ActivityFilter.comments,
      'Comments & Replies',
      'Peer discussions & answers',
      PhosphorIconsRegular.chatCircleDots,
    ),
    (
      ActivityFilter.questions,
      'Shared Questions',
      'MCQs and board problems',
      PhosphorIconsRegular.question,
    ),
    (
      ActivityFilter.notes,
      'Shared Notes',
      'Revision documents & formulas',
      PhosphorIconsRegular.bookBookmark,
    ),
    (
      ActivityFilter.upvotes,
      'Upvotes & Likes',
      'Posts you marked helpful',
      PhosphorIconsRegular.thumbsUp,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.headline('Filter Activity'),
                      const SizedBox(height: AppSpacing.xs),
                      AppText.caption(
                        'Select specific activity types',
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Reset',
                  variant: AppButtonVariant.text,
                  onPressed: () =>
                      setState(() => _selected = ActivityFilter.all),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  for (final option in _options)
                    _FilterOptionRow(
                      option: option,
                      count: widget.counts[option.$1] ?? 0,
                      isSelected: _selected == option.$1,
                      onTap: () => setState(() => _selected = option.$1),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                AppButton(
                  label: 'Apply Filter',
                  expand: true,
                  size: AppButtonSize.large,
                  onPressed: () => widget.onApply(_selected),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionRow extends StatelessWidget {
  const _FilterOptionRow({
    required this.option,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final (ActivityFilter, String, String, IconData) option;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Semantics(
        selected: isSelected,
        button: true,
        excludeSemantics: true,
        child: Container(
          color: isSelected ? AppColors.primarySoft : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(option.$4, size: AppSizes.iconMd, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.label(option.$2),
                    const SizedBox(height: 2),
                    AppText.caption(
                      option.$3,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              AppText.caption('$count', color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isSelected
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.circle,
                size: AppSizes.iconMd,
                color: isSelected ? AppColors.primary : AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
