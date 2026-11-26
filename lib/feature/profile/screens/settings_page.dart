// Displays app Settings: student summary, preferences, learning track,
// support links, legal policy, and confirmed sign-out.
import 'settings_page_imports.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.onOpenPrivacy,
    required this.onOpenSubscription,
    required this.onSignedOut,
  });

  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenSubscription;
  final VoidCallback onSignedOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.title('Settings')),
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state is SettingsLoaded) {
              if (state.actionError != null) {
                AppSnackBar.show(
                  context,
                  state.actionError!,
                  type: AppSnackBarType.error,
                );
              }
              if (state.signedOut) {
                onSignedOut();
              }
            }
          },
          builder: (context, state) {
            return switch (state) {
              SettingsInitial() || SettingsLoading() => const AppLoader(),
              SettingsError(:final message) => AppStateView.error(
                title: 'Could not load settings',
                message: message,
                onAction: () => context.read<SettingsCubit>().load(),
              ),
              SettingsLoaded(
                :final profile,
                :final settings,
                :final isSigningOut,
              ) =>
                _SettingsBody(
                  profile: profile,
                  settings: settings,
                  isSigningOut: isSigningOut,
                  onOpenPrivacy: onOpenPrivacy,
                  onOpenSubscription: onOpenSubscription,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.profile,
    required this.settings,
    required this.isSigningOut,
    required this.onOpenPrivacy,
    required this.onOpenSubscription,
  });

  final StudentProfile profile;
  final AppSettings settings;
  final bool isSigningOut;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenSubscription;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < AppSizes.narrowBreakpoint
        ? AppSpacing.lg
        : AppSpacing.gutter;
    final cubit = context.read<SettingsCubit>();

    return ListView(
      padding: EdgeInsets.all(gutter),
      children: [
        AppCard(
          radius: AppRadius.xl,
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: context.primarySoft,
                child: AppText.title(
                  profile.initials,
                  color: context.primaryStrong,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title(profile.fullName),
                    AppText.caption(
                      '${profile.targetExam} Batch • ${profile.academicGroup}',
                      color: AppColors.textSecondary,
                    ),
                    AppText.caption(
                      profile.email,
                      color: AppColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _notice(context, 'Edit profile'),
                child: const Text('Edit'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ProfileMenuSection(
          title: 'Account & Preferences',
          items: [
            ProfileMenuItem(
              icon: PhosphorIconsRegular.userCircle,
              title: 'Account',
              onTap: () => _notice(context, 'Account management'),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.crown,
              title: 'ChapterNo Plus',
              trailingBadge: 'PLUS',
              onTap: onOpenSubscription,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsToggleCard(
          items: [
            SettingsToggleItem(
              icon: PhosphorIconsRegular.bell,
              title: 'Notifications',
              value: settings.notificationsEnabled,
              onChanged: (v) => cubit.updateSettings(
                settings.copyWith(notificationsEnabled: v),
              ),
            ),
            SettingsToggleItem(
              icon: PhosphorIconsRegular.speakerHigh,
              title: 'Sound Effects',
              value: settings.soundEffectsEnabled,
              onChanged: (v) => cubit.updateSettings(
                settings.copyWith(soundEffectsEnabled: v),
              ),
            ),
            SettingsToggleItem(
              icon: PhosphorIconsRegular.vibrate,
              title: 'Haptics',
              value: settings.hapticsEnabled,
              onChanged: (v) =>
                  cubit.updateSettings(settings.copyWith(hapticsEnabled: v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        ProfileMenuSection(
          title: 'Learning & Display',
          items: [
            ProfileMenuItem(
              icon: PhosphorIconsRegular.compass,
              title: 'Learning Track',
              trailingText: settings.learningTrack.label,
              onTap: () => _pickTrack(context, settings),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.translate,
              title: 'Language',
              trailingText: settings.language.label,
              onTap: () => _pickLanguage(context, settings),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SettingsToggleCard(
          items: [
            SettingsToggleItem(
              icon: PhosphorIconsRegular.moon,
              title: 'Dark Mode',
              value: settings.darkModeEnabled,
              onChanged: (v) =>
                  cubit.updateSettings(settings.copyWith(darkModeEnabled: v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        ProfileMenuSection(
          title: 'Support & About',
          items: [
            ProfileMenuItem(
              icon: PhosphorIconsRegular.info,
              title: 'About ChapterNo',
              onTap: () => _notice(context, 'About ChapterNo'),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.question,
              title: 'Help & FAQ',
              onTap: () => _notice(context, 'Help & FAQ'),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.warningCircle,
              title: 'Report a Problem',
              onTap: () => _notice(context, 'Problem reporting'),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.sparkle,
              title: "What's New & Updates",
              onTap: () => _notice(context, 'Release notes'),
            ),
            ProfileMenuItem(
              icon: PhosphorIconsRegular.shieldCheck,
              title: 'Legal & Privacy Policy',
              onTap: onOpenPrivacy,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Log Out',
          variant: AppButtonVariant.outline,
          icon: PhosphorIconsRegular.signOut,
          isLoading: isSigningOut,
          onPressed: () => _confirmSignOut(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Center(
          child: AppText.caption(
            'ChapterNo • SSC Bangladesh',
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Future<void> _pickTrack(BuildContext context, AppSettings current) async {
    final cubit = context.read<SettingsCubit>();
    final selected = await showLearningTrackPicker(
      context,
      current.learningTrack,
    );
    if (selected != null && selected != current.learningTrack) {
      await cubit.updateSettings(current.copyWith(learningTrack: selected));
    }
  }

  Future<void> _pickLanguage(BuildContext context, AppSettings current) async {
    final cubit = context.read<SettingsCubit>();
    final selected = await showAppLanguagePicker(context, current.language);
    if (selected != null && selected != current.language) {
      await cubit.updateSettings(current.copyWith(language: selected));
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final cubit = context.read<SettingsCubit>();
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Log out of ChapterNo?',
      message: 'You can sign back in anytime with your email and password.',
      confirmLabel: 'Log Out',
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      await cubit.signOut();
    }
  }

  void _notice(BuildContext context, String label) {
    AppSnackBar.show(context, '$label will be available soon.');
  }
}
