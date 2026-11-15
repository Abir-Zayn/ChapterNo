// Renders the sample physics paper without revealing assessed answers.
// Question selection and session lifecycle belong to the parent screen.
import '../cq_imports.dart';

class CqExamContent extends StatelessWidget {
  const CqExamContent({
    super.key,
    required this.question,
    required this.onSelect,
  });
  final int question;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Physics · Chapter 2',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 8),
      Text('Motion', style: Theme.of(context).textTheme.headlineMedium),
      const Text('SSC practice paper · 3 creative questions · 30 marks'),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        children: List.generate(
          3,
          (i) => ChoiceChip(
            label: Text('CQ ${i + 1}'),
            selected: question == i,
            onSelected: (_) => onSelect(i),
          ),
        ),
      ),
      const SizedBox(height: 20),
      const AppCard(
        color: AppColors.primarySoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write on paper',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Keep your question numbers visible. You can add sample answer sheets after finishing this writing session.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CREATIVE QUESTION ${question + 1}  /  03',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 12),
            Text(
              [
                'Kinematics & acceleration',
                'Velocity–time graph & displacement',
                'Gravitational motion & free fall',
              ][question],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'STIMULUS',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              [
                'A car starts from rest and reaches 20 m/s in 8 seconds with uniform acceleration. It continues at this speed for 12 seconds before coming to rest in 6 seconds.',
                'Car A starts from rest with uniform acceleration. Car B travels at a constant velocity of 12 m/s. Both cars start from the same position at the same time.',
                'A student drops a ball from the roof of a building. Another ball is thrown vertically upward from the ground. Ignore air resistance and use g = 9.8 m/s².',
              ][question],
            ),
            const SizedBox(height: 20),
            const AspectRatio(
              aspectRatio: 1.8,
              child: CustomPaint(painter: MotionGraph()),
            ),
            const Text('Figure: sample velocity–time relationship'),
            const Divider(height: 32),
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  [
                    '(a) Define acceleration.                                      1 mark',
                    '(b) Explain uniform and non-uniform acceleration.    2 marks',
                    '(c) Calculate the acceleration using the stimulus.     3 marks',
                    '(d) Analyze the motion mathematically and justify your conclusion.    4 marks',
                  ][i],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class MotionGraph extends CustomPainter {
  const MotionGraph();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(24, size.height * i / 5),
        Offset(size.width - 12, size.height * i / 5),
        p,
      );
    }
    p
      ..color = AppColors.textSecondary
      ..strokeWidth = 2;
    canvas.drawLine(Offset(24, 12), Offset(24, size.height - 20), p);
    canvas.drawLine(
      Offset(24, size.height - 20),
      Offset(size.width - 12, size.height - 20),
      p,
    );
    p.color = AppColors.primary;
    canvas.drawLine(
      Offset(24, size.height - 20),
      Offset(size.width - 24, 24),
      p,
    );
    p.color = AppColors.accentMoss;
    canvas.drawLine(
      Offset(24, size.height / 2),
      Offset(size.width - 24, size.height / 2),
      p,
    );
  }

  @override
  bool shouldRepaint(MotionGraph oldDelegate) => false;
}
