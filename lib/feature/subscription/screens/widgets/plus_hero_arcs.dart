// Paints the two solid decorative arcs behind the Plus hero headline.
// Flat strokes only: no gradients, blur, or translucency (see DESIGN.md).
import 'widgets_imports.dart';

class PlusHeroArcs extends CustomPainter {
  const PlusHeroArcs();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.plusInkRaised
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16;
    final center = Offset(size.width * 1.08, size.height * 1.05);
    for (final factor in const [0.42, 0.78]) {
      final radius = size.width * factor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        3.4,
        1.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(PlusHeroArcs oldDelegate) => false;
}
