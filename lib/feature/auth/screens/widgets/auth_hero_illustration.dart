// Decorative student illustration for the welcome screen.
// Vector asset adapted from the Stitch reference without blur effects;
// hidden from screen readers because it carries no information.
import 'auth_widgets_imports.dart';

class AuthHeroIllustration extends StatelessWidget {
  const AuthHeroIllustration({super.key, this.maxSize = 240});

  static const String asset = 'assets/illustrations/auth_hero.svg';

  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize, maxHeight: maxSize),
        child: AspectRatio(
          aspectRatio: 1,
          child: SvgPicture.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
