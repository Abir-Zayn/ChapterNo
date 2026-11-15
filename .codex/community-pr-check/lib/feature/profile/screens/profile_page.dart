// Displays the Student Profile Dashboard with learning KPIs, cohort details,
// and navigation to Learning Analytics, Settings, and Sign Out.
import 'profile_page_imports.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.onOpenAnalytics,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenSettings;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.title('Profile')),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && state.actionError != null) {
              AppSnackBar.show(
                context,
                state.actionError!,
                type: AppSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const AppLoader(),
              ProfileError(:final message) => AppStateView.error(
                title: 'Could not load profile',
                message: message,
                onAction: () => context.read<ProfileCubit>().load(),
              ),
              ProfileLoaded(:final profile) => _ProfileContent(
                profile: profile,
                onOpenAnalytics: onOpenAnalytics,
                onOpenSettings: onOpenSettings,
                onSignOut: onSignOut,
              ),
            };
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.onOpenAnalytics,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  final StudentProfile profile;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenSettings;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < AppSizes.narrowBreakpoint
        ? AppSpacing.lg
        : AppSpacing.gutter;

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().load(),
      child: ListView(
        padding: EdgeInsets.all(gutter),
        children: [
          ProfileHeaderCard(
            profile: profile,
            onNotificationsTap: () => _comingSoon(context, 'Notifications'),
            onEditTap: () => _comingSoon(context, 'Edit profile'),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileStatGrid(
            items: [
              ProfileStatItem(
                label: 'MCQs Solved',
                value: '${profile.mcqsSolved}',
                subtitle: '+${profile.mcqsTodayDelta} today',
                icon: PhosphorIconsRegular.checkCircle,
                accentColor: AppColors.success,
                softBackground: AppColors.successSoft,
              ),
              ProfileStatItem(
                label: 'Accuracy',
                value: '${profile.accuracyPercent}%',
                subtitle: '↑ ${profile.accuracyDeltaPercent}%',
                icon: PhosphorIconsRegular.target,
                accentColor: AppColors.info,
                softBackground: AppColors.infoSoft,
              ),
              ProfileStatItem(
                label: 'CQ Practiced',
                value: '${profile.cqsPracticed}',
                subtitle: 'items',
                icon: PhosphorIconsRegular.pencilLine,
                accentColor: AppColors.warning,
                softBackground: AppColors.warningSoft,
              ),
              ProfileStatItem(
                label: 'Current Streak',
                value: '${profile.streakDays}',
                subtitle: 'Days active',
                icon: PhosphorIconsRegular.fire,
                accentColor: AppColors.primaryPressed,
                softBackground: AppColors.primarySoft,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfileMenuSection(
            title: 'My Learning Profile',
            headerBadge: profile.targetExam,
            items: [
              ProfileMenuItem(
                icon: PhosphorIconsRegular.graduationCap,
                title: 'Target Exam',
                trailingText: profile.targetExam,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.flask,
                title: 'Academic Group',
                trailingText: profile.academicGroup,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.sliders,
                title: 'Learning Pace',
                trailingText: profile.learningPace,
                onTap: () => _pickPace(context, profile.learningPace),
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.crown,
                title: 'Membership',
                trailingBadge: profile.membershipTier,
                onTap: () => _comingSoon(context, 'Membership plans'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfileCommunityCard(
            postsCount: profile.communityPostsCount,
            notesCount: profile.communityNotesCount,
            onTap: () => _comingSoon(context, 'Community profile'),
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfileMenuSection(
            title: 'My Learning',
            items: [
              ProfileMenuItem(
                icon: PhosphorIconsRegular.chartLineUp,
                title: 'Learning Analytics',
                trailingText: 'Weekly Report',
                onTap: onOpenAnalytics,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.fire,
                title: 'Daily Streak',
                trailingText: '${profile.streakDays} Days Active',
                onTap: onOpenAnalytics,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.medal,
                title: 'Leaderboard',
                trailingText: 'Rank #${profile.leaderboardRank}',
                onTap: () => _comingSoon(context, 'Leaderboard'),
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.calendar,
                title: 'Study Calendar',
                trailingText: '${profile.plannedStudyCount} Planned',
                onTap: () => _comingSoon(context, 'Study Calendar'),
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.clockCounterClockwise,
                title: 'Practice History',
                trailingText: 'View all',
                onTap: () => _comingSoon(context, 'Practice History'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfileMenuSection(
            title: 'Account & Security',
            items: [
              ProfileMenuItem(
                icon: PhosphorIconsRegular.identificationCard,
                title: 'Edit Profile Details',
                onTap: () => _comingSoon(context, 'Edit Profile Details'),
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.bellRinging,
                title: 'Notification Preferences',
                onTap: onOpenSettings,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.gearSix,
                title: 'App Settings & Language',
                onTap: onOpenSettings,
              ),
              ProfileMenuItem(
                icon: PhosphorIconsRegular.signOut,
                title: 'Log Out',
                isDestructive: true,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Center(
            child: AppText.caption(
              'ChapterNo Learning • SSC Bangladesh',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _pickPace(BuildContext context, String currentPace) async {
    final cubit = context.read<ProfileCubit>();
    final selected = await showLearningPacePicker(context, currentPace);
    if (selected != null && selected != currentPace) {
      await cubit.updateLearningPace(selected);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Log out of ChapterNo?',
      message: 'You can sign back in anytime with your email and password.',
      confirmLabel: 'Log Out',
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      await onSignOut();
    }
  }

  void _comingSoon(BuildContext context, String feature) {
    AppSnackBar.show(context, '$feature will be available soon.');
  }
}
