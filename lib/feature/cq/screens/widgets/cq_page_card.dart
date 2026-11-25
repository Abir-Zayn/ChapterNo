// Displays a clearly labelled sample manuscript and editing controls.
// Parent callbacks apply rotation, assignment, deletion, and ordering locally.
import '../cq_imports.dart';

class CqPageCard extends StatelessWidget {
  const CqPageCard({
    super.key,
    required this.id,
    required this.turns,
    required this.onRotate,
    required this.onDelete,
    required this.onMove,
    required this.onAssign,
  });
  final int id, turns;
  final VoidCallback onRotate, onDelete, onMove;
  final ValueChanged<int> onAssign;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Sample page $id',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Move page earlier',
              onPressed: onMove,
              icon: const Icon(PhosphorIconsRegular.arrowUp),
            ),
            IconButton(
              tooltip: 'Remove page',
              onPressed: onDelete,
              icon: const Icon(PhosphorIconsRegular.trash),
            ),
          ],
        ),
        const Text('Demo manuscript · not an uploaded photo'),
        const SizedBox(height: 12),
        Semantics(
          label: 'Sample answer sheet preview',
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRect(
              child: RotatedBox(
                quarterTurns: turns,
                child: const SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PHYSICS  /  ANSWER SCRIPT'),
                        Divider(),
                        Text(
                          'v = u + at',
                          style: TextStyle(
                            fontSize: 22,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Divider(),
                        Text('Displacement = area under the v–t graph'),
                        Divider(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: onRotate,
              icon: const Icon(PhosphorIconsRegular.arrowClockwise),
              label: const Text('Rotate'),
            ),
            PopupMenuButton<int>(
              tooltip: 'Assign to question',
              onSelected: onAssign,
              itemBuilder: (_) => List.generate(
                3,
                (i) => PopupMenuItem(
                  value: i,
                  child: Text('Assign to CQ ${i + 1}'),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Reassign to CQ…'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
