// Displays the Student Home Dashboard: daily targets, streaks, and subject mastery.
// Listens to HomeCubit for state transitions and coordinates user study actions.
import 'home_page_imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeNavTab _currentTab = HomeNavTab.home;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth <= AppSizes.narrowBreakpoint;
    final horizontalGutter = isNarrow ? AppSpacing.lg : AppSpacing.gutter;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() || HomeLoading() => const Center(
                child: AppLoader(message: 'Loading your dashboard...'),
              ),
              HomeError(:final message) => AppStateView(
                icon: PhosphorIconsRegular.warningCircle,
                title: 'Unable to Load Dashboard',
                message: message,
                actionLabel: 'Try Again',
                onAction: () => context.read<HomeCubit>().loadDashboard(),
              ),
              HomeLoaded(:final dashboard) => RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<HomeCubit>().refreshDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalGutter,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        studentName: dashboard.studentName,
                        cohortTitle: dashboard.cohortTitle,
                        streakDays: dashboard.currentStreakDays,
                        chapterCoins: dashboard.chapterCoins,
                        onNotificationTap: () => AppSnackBar.show(
                          context,
                          'No new notifications right now.',
                        ),
                        onProfileTap: widget.onSignOut,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      DailyGoalCard(
                        goal: dashboard.dailyGoal,
                        onContinuePractice: () {
                          context.read<HomeCubit>().advanceDailyGoal();
                          AppSnackBar.show(
                            context,
                            'Resuming ${dashboard.dailyGoal.chapterTitle}',
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ContinueLearningCard(
                        session: dashboard.activeSession,
                        onResume: () => AppSnackBar.show(
                          context,
                          'Resuming ${dashboard.activeSession.chapterTitle}',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const AppText.title(
                        'Quick Study',
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      QuickActionsGrid(
                        onActionSelected: (mode) => AppSnackBar.show(
                          context,
                          'Opening $mode study mode...',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SubjectMasterySection(
                        subjects: dashboard.subjects,
                        onSubjectSelected: (subject) => AppSnackBar.show(
                          context,
                          '${subject.subjectName}: ${subject.masteryPercentage}% mastery',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      RecentActivitySection(
                        activities: dashboard.recentActivities,
                        onActivityTap: (activity) => AppSnackBar.show(
                          context,
                          'Reviewed ${activity.title}',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            };
          },
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentTab: _currentTab,
        onTabSelected: (tab) {
          setState(() => _currentTab = tab);
          if (tab == HomeNavTab.profile) {
            _showProfileOptions(context);
          } else if (tab != HomeNavTab.home) {
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
                  widget.onSignOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
