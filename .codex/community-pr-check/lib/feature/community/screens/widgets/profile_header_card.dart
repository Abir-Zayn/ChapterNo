// Presents the public sample identity and contribution counts.
// Keeps profile details readable on narrow screens and enlarged text.
import 'profile_header_card_dependencies.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile, this.onEdit});
  final CommunityProfile profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityAvatar(initials: profile.initials, size: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.headline(profile.displayName),
                  AppText.caption(
                    profile.handle,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (profile.verified) const Text('SSC student'),
                ],
              ),
            ),
            AppIconButton(
              icon: PhosphorIconsRegular.pencilSimple,
              tooltip: 'Edit community profile',
              onPressed: onEdit,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SubjectTag(label: profile.batchLabel),
        const SizedBox(height: AppSpacing.md),
        AppText(profile.bio),
        const SizedBox(height: AppSpacing.sm),
        AppText.caption(
          'Sample community profile',
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileStatsRow(stats: profile.stats),
      ],
    ),
  );
}
