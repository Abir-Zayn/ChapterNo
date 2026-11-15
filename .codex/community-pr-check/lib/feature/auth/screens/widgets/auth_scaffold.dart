// Page frame shared by auth screens: safe area, scrolling, and gutters.
// Content scrolls when the keyboard or large text needs room, the footer
// rests at the bottom when space allows, and width is capped on tablets.
import 'auth_back_button.dart';
import 'auth_widgets_imports.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    this.footer,
    this.showBack = false,
  });

  static const double _top = AppSpacing.sm;
  static const double _bottom = AppSpacing.lg;

  final Widget body;

  /// Pinned to the bottom edge when the content is shorter than the screen.
  final Widget? footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final bottom = footer;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < AppSizes.narrowBreakpoint
                ? AppSpacing.lg
                : AppSpacing.gutter;
            // Side padding grows on wide screens to cap the reading width.
            final side = ((constraints.maxWidth - AppSizes.contentMaxWidth) / 2)
                .clamp(gutter, double.infinity);
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(side, _top, side, _bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - _top - _bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showBack) const AuthBackButton(),
                      body,
                      if (bottom != null) ...[
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xl),
                        bottom,
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
