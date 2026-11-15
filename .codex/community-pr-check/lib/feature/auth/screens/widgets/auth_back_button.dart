// Circular back button used at the top of auth and legal screens.
// Pops the current route when possible; labelled for screen readers.
import 'auth_widgets_imports.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppIconButton(
          icon: PhosphorIconsRegular.arrowLeft,
          tooltip: 'Back',
          variant: AppIconButtonVariant.outlined,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
