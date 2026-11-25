// Community guidelines callout for create-post forms. Shows either a short
// message or a bullet list; icon plus text so meaning never rides on color.
import 'community_widgets_imports.dart';

class GuidelinesCard extends StatelessWidget {
  const GuidelinesCard({super.key, required this.title, this.message})
    : bullets = const [];

  const GuidelinesCard.bullets({
    super.key,
    required this.title,
    required this.bullets,
  }) : message = null;

  final String title;
  final String? message;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    return AppCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsRegular.shieldCheck,
                size: AppSizes.iconMd,
                color: AppColors.accentMoss,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: AppText.label(title)),
            ],
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText.caption(
              message,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ],
          if (bullets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final bullet in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText.caption(
                        bullet,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
