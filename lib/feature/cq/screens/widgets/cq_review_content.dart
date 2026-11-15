// Composes question tabs and editable or read-only sample pages.
// Sends local edits to the owning preview state through callbacks.
import '../cq_imports.dart';

List<Widget> cqReviewContent(
  BuildContext context, {
  required List<({int id, int cq, int turns})> pages,
  required bool readOnly,
  required int question,
  required void Function(int) onQuestion,
  required void Function(int) addPage,
  required void Function(void Function()) update,
}) => [
  Text(
    readOnly ? 'Submitted sample pages' : 'Review your answers',
    style: Theme.of(context).textTheme.headlineSmall,
  ),
  const SizedBox(height: 8),
  Text(
    readOnly
        ? 'Read-only demo submission.'
        : 'Check the order and question assignment of every page.',
  ),
  const SizedBox(height: 16),
  Wrap(
    spacing: 8,
    children: List.generate(
      3,
      (cq) => ChoiceChip(
        label: Text(
          'CQ ${cq + 1} · ${pages.where((p) => p.cq == cq).length} pages',
        ),
        selected: question == cq,
        onSelected: (_) => onQuestion(cq),
      ),
    ),
  ),
  const SizedBox(height: 20),
  if (!pages.any((p) => p.cq == question))
    AppCard(
      child: Column(
        children: [
          const Text('No pages for this question'),
          if (!readOnly)
            TextButton(
              onPressed: () => addPage(question),
              child: const Text('Add sample page'),
            ),
        ],
      ),
    ),
  ...pages
      .where((p) => p.cq == question)
      .map(
        (page) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: readOnly
              ? AppCard(
                  child: Text(
                    'Sample page ${page.id} · CQ ${page.cq + 1} · rotation ${page.turns % 4 * 90}°',
                  ),
                )
              : CqPageCard(
                  key: ValueKey(page.id),
                  id: page.id,
                  turns: page.turns,
                  onRotate: () => update(() {
                    final i = pages.indexOf(page);
                    pages[i] = (
                      id: page.id,
                      cq: page.cq,
                      turns: page.turns + 1,
                    );
                  }),
                  onDelete: () => update(() => pages.remove(page)),
                  onMove: () => update(() {
                    final i = pages.indexOf(page);
                    final previous = pages.lastIndexWhere(
                      (p) => p.cq == page.cq,
                      i - 1,
                    );
                    if (i > 0 && previous >= 0) {
                      pages.removeAt(i);
                      pages.insert(previous, page);
                    }
                  }),
                  onAssign: (cq) => update(() {
                    final i = pages.indexOf(page);
                    pages[i] = (id: page.id, cq: cq, turns: page.turns);
                  }),
                ),
        ),
      ),
  if (!readOnly)
    TextButton.icon(
      onPressed: () => addPage(question),
      icon: const Icon(PhosphorIconsRegular.plus),
      label: const Text('Add sample page'),
    ),
  const SizedBox(height: 12),
  Text(
    '${pages.length} pages total · ${3 - pages.map((p) => p.cq).toSet().length} unanswered questions',
  ),
  const SizedBox(height: 12),
  const Text(
    'In this demo, scripts remain on this screen only. Production AI feedback will provide estimated marks.',
  ),
];
