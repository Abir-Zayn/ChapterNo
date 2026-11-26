// Education board and learning pace selectors for the Onboarding form.
// Each opens a bottom sheet matching the Settings picker pattern.
import 'widgets_imports.dart';

class BoardSelectorField extends StatelessWidget {
  const BoardSelectorField({
    super.key,
    required this.boards,
    required this.isLoading,
    this.boardsError,
    required this.selectedBoard,
    required this.onSelected,
    required this.onRetry,
  });

  final List<OnboardingBoard> boards;
  final bool isLoading;
  final String? boardsError;
  final OnboardingBoard? selectedBoard;
  final ValueChanged<OnboardingBoard> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasBoards = boards.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          // Tapping a failed field retries the board load instead of
          // opening an empty sheet.
          onTap: hasBoards
              ? () => _pickBoard(context)
              : (boardsError == null ? null : onRetry),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.graduationCap,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppText(
                  selectedBoard?.name ?? 'Select your board',
                  color: selectedBoard == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontWeight: selectedBoard == null
                      ? FontWeight.w400
                      : FontWeight.w600,
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretDown,
                size: AppSizes.iconSm,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: AppSpacing.xs),
          const AppText.caption('Loading boards…'),
        ],
        if (boardsError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText.caption(boardsError!, color: AppColors.error),
        ],
      ],
    );
  }

  Future<void> _pickBoard(BuildContext context) async {
    final board = await showModalBottomSheet<OnboardingBoard>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        // Eleven boards overflow small screens inside a non-scrollable
        // sheet, so the list scrolls.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppText.title('Select your board'),
              ),
              for (final board in boards)
                ListTile(
                  title: AppText(board.name),
                  trailing: board == selectedBoard
                      ? Icon(PhosphorIconsRegular.check, color: context.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(board),
                ),
            ],
          ),
        ),
      ),
    );
    if (board != null) onSelected(board);
  }
}

class LearningPaceSelectorField extends StatelessWidget {
  const LearningPaceSelectorField({
    super.key,
    required this.selectedPace,
    required this.onSelected,
  });

  /// Stored pace value: 'casual', 'standard', or 'intensive'.
  final String selectedPace;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _pickPace(context),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.gauge, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              OnboardingDraft.labelForPace(selectedPace),
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretDown,
            size: AppSizes.iconSm,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Future<void> _pickPace(BuildContext context) async {
    final pace = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: AppText.title('Select learning pace'),
            ),
            for (final option in OnboardingDraft.learningPaceOptions)
              ListTile(
                title: AppText(option.label),
                trailing: option.value == selectedPace
                    ? Icon(PhosphorIconsRegular.check, color: context.primary)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(option.value),
              ),
          ],
        ),
      ),
    );
    if (pace != null) onSelected(pace);
  }
}
