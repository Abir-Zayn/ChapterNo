// Header row shared by ranked quiz screens: leading action, centered
// eyebrow + title, and an optional trailing widget.
import 'ranked_widgets_imports.dart';

class RankedTopBar extends StatelessWidget {
  const RankedTopBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.leadingIcon = PhosphorIconsRegular.arrowLeft,
    this.leadingTooltip = 'Back',
    this.onLeading,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final IconData leadingIcon;
  final String leadingTooltip;
  final VoidCallback? onLeading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          RankedSquareIconButton(
            icon: leadingIcon,
            tooltip: leadingTooltip,
            onPressed: onLeading,
          ),
          Expanded(
            child: Column(
              children: [
                if (eyebrow != null)
                  AppText.caption(
                    eyebrow!.toUpperCase(),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                AppText.title(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox(width: AppSizes.minTouch),
        ],
      ),
    );
  }
}

class RankedSquareIconButton extends StatelessWidget {
  const RankedSquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceSunken,
        minimumSize: const Size.square(AppSizes.minTouch),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      icon: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
    );
  }
}
