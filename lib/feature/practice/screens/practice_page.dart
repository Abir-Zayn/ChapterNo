// Displays the Practice Dashboard matching Stitch design: overview, recent quiz sessions, and modes.
// Listens to PracticeCubit for state updates, quiz resume triggers, and review actions.
import 'practice_page_imports.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({
    super.key,
    required this.onNavigateToHome,
    required this.onSignOut,
  });

  final VoidCallback onNavigateToHome;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth <= AppSizes.narrowBreakpoint;
    final horizontalGutter = isNarrow ? AppSpacing.lg : AppSpacing.gutter;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PracticeAppBar(
              onNotificationTap: () =>
                  AppSnackBar.show(context, 'You have no new notifications.'),
              onProfileTap: () => _showProfileOptions(context),
            ),
            Expanded(
              child: BlocBuilder<PracticeCubit, PracticeState>(
                builder: (context, state) {
                  return switch (state) {
                    PracticeInitial() || PracticeLoading() => const Center(
                      child: AppLoader(message: 'Loading practice sessions...'),
                    ),
                    PracticeError(:final message) => AppStateView(
                      icon: PhosphorIconsRegular.warningCircle,
                      title: 'Unable to Load Practice',
                      message: message,
                      actionLabel: 'Try Again',
                      onAction: () =>
                          context.read<PracticeCubit>().loadDashboard(),
                    ),
                    PracticeLoaded(:final data) => RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          context.read<PracticeCubit>().refreshDashboard(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalGutter,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PracticeGreetingHeader(
                              onSearchTap: () => AppSnackBar.show(
                                context,
                                'Search practice topics...',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PracticeOverviewCard(metrics: data.overview),
                            const SizedBox(height: AppSpacing.xl),
                            RecentQuizActivitySection(
                              activities: data.recentActivities,
                              onViewAll: () => AppSnackBar.show(
                                context,
                                'Opening all quiz sessions...',
                              ),
                              onActionTap: (activity) {
                                if (activity.status ==
                                    QuizActivityStatus.inProgress) {
                                  context.read<PracticeCubit>().resumeQuiz(
                                    activity.id,
                                  );
                                  AppSnackBar.show(
                                    context,
                                    'Resuming ${activity.fullTitle}...',
                                  );
                                } else {
                                  context.read<PracticeCubit>().reviewResults(
                                    activity.id,
                                  );
                                  AppSnackBar.show(
                                    context,
                                    'Reviewing results for ${activity.fullTitle}...',
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            StartPracticeGrid(
                              modes: data.practiceModes,
                              onModeSelected: (mode) => AppSnackBar.show(
                                context,
                                'Opening ${mode.title}...',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            StreakMilestoneBanner(milestone: data.milestone),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentTab: HomeNavTab.practice,
        onTabSelected: (tab) {
          if (tab == HomeNavTab.home) {
            onNavigateToHome();
          } else if (tab == HomeNavTab.profile) {
            _showProfileOptions(context);
          } else if (tab != HomeNavTab.practice) {
            AppSnackBar.show(
              context,
              '${tab.name.toUpperCase()} tab is coming soon.',
            );
          }
        },
      ),
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (bottomContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.title(
                'Student Account',
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: AppSpacing.sm),
              const AppText(
                'Signed in as Siam (SSC 2026 Batch)',
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.danger,
                expand: true,
                onPressed: () {
                  Navigator.of(bottomContext).pop();
                  onSignOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
