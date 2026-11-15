// Create-post flow: one header with cancel and Publish, a pill type
// switcher, and the form for the selected post kind. Typed text lives in
// this page's controllers so switching types keeps what was entered.
import 'create_post_page_dependencies.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({
    super.key,
    required this.onPublished,
    required this.onCancel,
  });

  /// Navigates back to the feed after a successful publish.
  final VoidCallback onPublished;

  /// Dismisses the page without publishing.
  final VoidCallback onCancel;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _publish() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CreatePostCubit>().publish(
      title: _titleController.text,
      body: _bodyController.text,
    );
  }

  void _notAvailable(String feature) {
    AppSnackBar.show(context, '$feature is not available yet.');
  }

  void _onStateChanged(BuildContext context, CreatePostState state) {
    switch (state.status) {
      case CreatePostStatus.success:
        AppSnackBar.show(
          context,
          'Added to the local Community preview.',
          type: AppSnackBarType.success,
        );
        widget.onPublished();
      case CreatePostStatus.failure:
        final issue = state.issues.firstOrNull;
        final message = issue?.message ?? state.failure?.message;
        if (message != null) {
          AppSnackBar.show(context, message, type: AppSnackBarType.error);
        }
        context.read<CreatePostCubit>().reset();
      case CreatePostStatus.idle:
      case CreatePostStatus.publishing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final busy = state.isPublishing;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: AppIconButton(
              icon: PhosphorIconsRegular.x,
              tooltip: 'Cancel',
              onPressed: busy ? null : widget.onCancel,
            ),
            title: AppText.title('Create Post'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AppButton(
                  label: 'Publish',
                  isLoading: busy,
                  onPressed: _publish,
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: PillSegmentedControl<CommunityPostKind>(
                    segments: const [
                      PillSegment(
                        value: CommunityPostKind.discussion,
                        label: 'Discussion',
                        icon: PhosphorIconsRegular.chatTeardropText,
                      ),
                      PillSegment(
                        value: CommunityPostKind.question,
                        label: 'Practice Question',
                        icon: PhosphorIconsRegular.question,
                      ),
                      PillSegment(
                        value: CommunityPostKind.notes,
                        label: 'PDF Notes',
                        icon: PhosphorIconsRegular.fileText,
                      ),
                    ],
                    selected: state.type,
                    enabled: !busy,
                    onSelected: context.read<CreatePostCubit>().setType,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.huge,
                    ),
                    child: Form(
                      key: _formKey,
                      child: switch (state.type) {
                        CommunityPostKind.discussion =>
                          CreatePostDiscussionForm(
                            titleController: _titleController,
                            bodyController: _bodyController,
                            subject: state.subject,
                            onSubjectSelected: context
                                .read<CreatePostCubit>()
                                .setSubject,
                            onFeatureUnavailable: _notAvailable,
                          ),
                        CommunityPostKind.question => CreatePostQuestionForm(
                          titleController: _titleController,
                          bodyController: _bodyController,
                          state: state,
                          onFeatureUnavailable: _notAvailable,
                        ),
                        CommunityPostKind.notes => CreatePostNotesForm(
                          titleController: _titleController,
                          bodyController: _bodyController,
                          state: state,
                          onSubjectSelected: context
                              .read<CreatePostCubit>()
                              .setSubject,
                          onChapterSelected: context
                              .read<CreatePostCubit>()
                              .setChapter,
                          onFeatureUnavailable: _notAvailable,
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
