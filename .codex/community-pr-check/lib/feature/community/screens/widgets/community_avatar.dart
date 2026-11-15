// Initials avatar for community members on solid tinted circles.
// Color derives from the initials so the same student looks consistent.
import 'community_widgets_imports.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.semanticsLabel,
  });

  final String initials;
  final double size;

  /// Optional description for screen readers, e.g. 'Tanvir R.'.
  final String? semanticsLabel;

  static const List<Color> _tints = [
    AppColors.accentMoss,
    AppColors.accentClay,
    AppColors.accentAmber,
  ];

  Color _tintFor(String value) {
    var hash = 0;
    for (final code in value.codeUnits) {
      hash = (hash + code) % _tints.length;
    }
    return _tints[hash];
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tintFor(initials);
    final label = semanticsLabel;
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppText.label(
        initials,
        color: tint,
        fontWeight: FontWeight.w700,
        maxLines: 1,
      ),
    );
    if (label == null) return circle;
    return Semantics(label: label, child: circle);
  }
}
