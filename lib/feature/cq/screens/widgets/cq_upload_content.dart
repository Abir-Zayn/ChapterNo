// Composes mock answer-sheet groups and sample attachment actions.
// Delegates page changes and navigation to the owning preview.
import '../cq_imports.dart';

List<Widget> cqUploadContent(
  BuildContext context, {
  required List<({int id, int cq, int turns})> pages,
  required void Function(int) addPage,
  required void Function(int) onReview,
}) => [
  Text(
    'Script upload & verification',
    style: Theme.of(context).textTheme.headlineSmall,
  ),
  const SizedBox(height: 8),
  const Text('Physics · Chapter 2: Motion\n3 creative questions · 30 marks'),
  const SizedBox(height: 20),
  const AppCard(
    color: AppColors.primarySoft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A clear page makes a difference',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text(
          'Use good lighting, flatten the paper, and keep all four corners visible.',
        ),
      ],
    ),
  ),
  const SizedBox(height: 20),
  ...List.generate(3, (cq) {
    final count = pages.where((p) => p.cq == cq).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CQ ${cq + 1} · 10 marks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              [
                'Kinematics & acceleration',
                'Velocity–time graph & displacement',
                'Gravitational motion & free fall',
              ][cq],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(PhosphorIconsRegular.files),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    count == 0
                        ? 'No sample pages attached'
                        : '$count sample pages attached',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Add sample page',
              icon: PhosphorIconsRegular.plus,
              variant: AppButtonVariant.outline,
              onPressed: () => addPage(cq),
            ),
            if (count > 0)
              TextButton(
                onPressed: () => onReview(cq),
                child: const Text('Review & organize pages'),
              ),
          ],
        ),
      ),
    );
  }),
  const Text(
    'Camera and gallery integration are outside this UI preview. Sample pages reset when you leave the flow.',
  ),
];
