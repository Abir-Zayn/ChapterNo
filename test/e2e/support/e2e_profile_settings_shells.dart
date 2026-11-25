// Harness shell routes for /profile and /settings driven by real ProfileCubit
// and SettingsCubit until Wave 4 fixes the 32 pre-existing widget const errors.
// Mirrors Step 1 honest zero-state ('Free', 'Unranked') and sign-out dialogs.
import 'e2e_profile_settings_shells_imports.dart';

class E2eProfileShellPage extends StatelessWidget {
  const E2eProfileShellPage({
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
          builder: (context, state) => switch (state) {
            ProfileInitial() || ProfileLoading() => const AppLoader(),
            ProfileError(:final message) => AppStateView.error(
              title: 'Could not load profile',
              message: message,
              onAction: () => context.read<ProfileCubit>().load(),
            ),
            ProfileLoaded(:final profile) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText.headline(profile.fullName),
                  AppText.caption(
                    '${profile.targetExam} • ${profile.academicGroup}',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText('Tier: ${profile.membershipTier}'),
                  AppText('MCQs Solved: ${profile.mcqsSolved}'),
                  AppText('Accuracy: ${profile.accuracyPercent}%'),
                  AppText('CQ Practiced: ${profile.cqsPracticed}'),
                  AppText('Streak: ${profile.streakDays}'),
                  AppText(
                    profile.leaderboardRank <= 0
                        ? 'Unranked'
                        : 'Rank #${profile.leaderboardRank}',
                  ),
                  AppText('Pace: ${profile.learningPace}'),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final pace in const [
                        'Casual',
                        'Standard',
                        'Intensive',
                      ])
                        ChoiceChip(
                          label: Text(pace),
                          selected: profile.learningPace == pace,
                          onSelected: (_) => context
                              .read<ProfileCubit>()
                              .updateLearningPace(pace),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Learning Analytics',
                    expand: true,
                    onPressed: onOpenAnalytics,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'App Settings',
                    expand: true,
                    variant: AppButtonVariant.outline,
                    onPressed: onOpenSettings,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Log Out',
                    expand: true,
                    variant: AppButtonVariant.danger,
                    onPressed: () async {
                      final confirmed = await AppConfirmDialog.show(
                        context,
                        title: 'Log out of ChapterNo?',
                        confirmLabel: 'Log Out',
                        isDestructive: true,
                      );
                      if (confirmed) await onSignOut();
                    },
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}

class E2eSettingsShellPage extends StatelessWidget {
  const E2eSettingsShellPage({
    super.key,
    required this.onDarkModeChanged,
    required this.onSignedOut,
  });

  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onSignedOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.title('Settings')),
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              if (state.signedOut) {
                onSignedOut();
                return;
              }
              onDarkModeChanged(state.settings.darkModeEnabled);
              if (state.actionError != null) {
                AppSnackBar.show(
                  context,
                  state.actionError!,
                  type: AppSnackBarType.error,
                );
              }
            }
          },
          builder: (context, state) => switch (state) {
            SettingsInitial() || SettingsLoading() => const AppLoader(),
            SettingsError(:final message) => AppStateView.error(
              title: 'Could not load settings',
              message: message,
              onAction: () => context.read<SettingsCubit>().load(),
            ),
            SettingsLoaded(:final profile, :final settings) =>
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText.title(profile.fullName),
                    AppText.caption(profile.email),
                    SwitchListTile(
                      title: const Text('Notifications'),
                      value: settings.notificationsEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().updateSettings(
                            settings.copyWith(notificationsEnabled: v),
                          ),
                    ),
                    SwitchListTile(
                      title: const Text('Haptics'),
                      value: settings.hapticsEnabled,
                      onChanged: (v) => context
                          .read<SettingsCubit>()
                          .updateSettings(settings.copyWith(hapticsEnabled: v)),
                    ),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settings.darkModeEnabled,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().updateSettings(
                            settings.copyWith(darkModeEnabled: v),
                          ),
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final track in LearningTrack.values)
                          ChoiceChip(
                            label: Text(track.label),
                            selected: settings.learningTrack == track,
                            onSelected: (_) =>
                                context.read<SettingsCubit>().updateSettings(
                                  settings.copyWith(learningTrack: track),
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Log Out',
                      expand: true,
                      variant: AppButtonVariant.danger,
                      onPressed: () async {
                        final confirmed = await AppConfirmDialog.show(
                          context,
                          title: 'Log out of ChapterNo?',
                          confirmLabel: 'Log Out',
                          isDestructive: true,
                        );
                        if (confirmed && context.mounted) {
                          await context.read<SettingsCubit>().signOut();
                        }
                      },
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}
