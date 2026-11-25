// Presents a manually advanced evaluation demo and read-only submission.
// Makes no claim of network upload, AI execution, or notification delivery.
import '../cq_imports.dart';

class CqProcessingContent extends StatelessWidget {
  const CqProcessingContent({
    super.key,
    required this.count,
    required this.complete,
    required this.onAdvance,
    required this.onView,
  });
  final int count;
  final bool complete;
  final VoidCallback onAdvance, onView;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 16),
      const CircleAvatar(
        radius: 36,
        backgroundColor: AppColors.successSoft,
        child: Icon(
          PhosphorIconsRegular.check,
          size: 36,
          color: AppColors.success,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Submission preview ready',
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      const Text(
        'Your sample pages are kept in this preview only. Nothing has been uploaded.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physics · Chapter 2: Motion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('$count sample manuscript pages'),
            const Divider(height: 32),
            Text(
              complete ? 'Demo evaluation complete' : 'Evaluating your answers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: complete ? 1 : .64),
            const SizedBox(height: 20),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(PhosphorIconsRegular.checkCircle),
              title: Text('Document reading'),
              subtitle: Text('Simulated · sample pages recognized'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                complete
                    ? PhosphorIconsRegular.checkCircle
                    : PhosphorIconsRegular.circleHalf,
              ),
              title: const Text('Rubric & step analysis'),
              subtitle: Text(
                complete
                    ? 'Simulated analysis complete'
                    : 'Demo stage · no AI service connected',
              ),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(PhosphorIconsRegular.note),
              title: Text('Feedback & estimated marks'),
              subtitle: Text(
                'AI marks are estimates, not final teacher or board marks.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const AppCard(
        color: AppColors.primarySoft,
        child: Text(
          'UI demo only. No coins are charged and no notifications are sent. Progress changes only when you advance the demo.',
        ),
      ),
      const SizedBox(height: 20),
      AppButton(
        label: complete ? 'Demo complete' : 'Advance demo progress',
        onPressed: complete ? null : onAdvance,
        expand: true,
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: onView,
        child: const Text('View submitted sample pages'),
      ),
    ],
  );
}
