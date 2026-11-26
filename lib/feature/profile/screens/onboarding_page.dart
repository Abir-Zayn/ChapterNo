// Onboarding gate form: collects display name, SSC batch year, board,
// academic group, and learning pace before the student reaches Home.
import 'onboarding_page_imports.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _displayNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit(OnboardingCubit cubit) {
    if (_formKey.currentState!.validate()) cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.completed) {
          widget.onCompleted();
        } else if (state.actionError != null) {
          AppSnackBar.show(
            context,
            state.actionError!,
            type: AppSnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        return Scaffold(
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const AppText.headline('Set up your learning profile'),
                  const SizedBox(height: AppSpacing.xs),
                  const AppText(
                    'Tell us a little about you so ChapterNo can fit your '
                    'study plan.',
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _displayNameController,
                    label: 'Display name',
                    hint: 'How should we show your name?',
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.words,
                    onChanged: cubit.updateDisplayName,
                    validator: OnboardingDraft.validateDisplayName,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppText.label('SSC batch'),
                  const SizedBox(height: AppSpacing.sm),
                  BatchYearChips(
                    selectedYear: state.batchYear,
                    onSelected: cubit.selectBatchYear,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppText.label('Education board'),
                  const SizedBox(height: AppSpacing.sm),
                  BoardSelectorField(
                    boards: state.boards,
                    isLoading: state.isLoadingBoards,
                    boardsError: state.boardsError,
                    selectedBoard: state.board,
                    onSelected: cubit.selectBoard,
                    onRetry: cubit.loadBoards,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppText.label('Academic group'),
                  const SizedBox(height: AppSpacing.sm),
                  AcademicGroupSelector(
                    selectedGroup: state.academicGroup,
                    onSelected: cubit.selectAcademicGroup,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AppText.label('Learning pace'),
                  const SizedBox(height: AppSpacing.sm),
                  LearningPaceSelectorField(
                    selectedPace: state.learningPace,
                    onSelected: cubit.selectLearningPace,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Save and continue',
                    size: AppButtonSize.large,
                    expand: true,
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmit ? () => _submit(cubit) : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
