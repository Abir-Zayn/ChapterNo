// Owns the local, disposable CQ design preview from writing to evaluation.
// All manuscript edits are in memory; no camera, storage, or AI is connected.
import 'cq_imports.dart';

class CqFlowPage extends StatefulWidget {
  const CqFlowPage({super.key});
  @override
  State<CqFlowPage> createState() => _CqFlowPageState();
}

class _CqFlowPageState extends State<CqFlowPage> {
  int step = 0, question = 0, remaining = 3600, nextId = 6;
  bool started = false, complete = false, readOnly = false;
  Timer? timer;
  final pages = <({int id, int cq, int turns})>[
    (id: 1, cq: 0, turns: 0),
    (id: 2, cq: 0, turns: 0),
    (id: 3, cq: 1, turns: 0),
    (id: 4, cq: 1, turns: 0),
    (id: 5, cq: 1, turns: 0),
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start() {
    setState(() => started = true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remaining--;
        if (remaining == 0) {
          timer?.cancel();
          step = 1;
        }
      });
    });
  }

  Future<void> finish() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish writing?'),
        content: const Text(
          'Your writing timer will stop. Next, arrange sample answer sheets for this UI preview.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep writing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish session'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      timer?.cancel();
      setState(() => step = 1);
    }
  }

  void addPage(int cq) =>
      setState(() => pages.add((id: nextId++, cq: cq, turns: 0)));

  void back() {
    if (readOnly) {
      setState(() {
        readOnly = false;
        step = 3;
      });
    } else if (step == 2) {
      setState(() => step = 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Timed CQ examination',
      'Submit answer sheets',
      'Review & organize',
      'Submission & evaluation',
    ];
    return PopScope(
      canPop: step != 2,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            onPressed: back,
            icon: const Icon(PhosphorIconsRegular.arrowLeft),
          ),
          title: Text(titles[step]),
          actions: [
            if (step == 0)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'UI PREVIEW · MOCK DATA',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (step == 0)
                  CqExamContent(
                    question: question,
                    onSelect: (value) => setState(() => question = value),
                  ),
                if (step == 1)
                  ...cqUploadContent(
                    context,
                    pages: pages,
                    addPage: addPage,
                    onReview: (cq) => setState(() {
                      question = cq;
                      step = 2;
                    }),
                  ),
                if (step == 2)
                  ...cqReviewContent(
                    context,
                    pages: pages,
                    readOnly: readOnly,
                    question: question,
                    onQuestion: (cq) => setState(() => question = cq),
                    addPage: addPage,
                    update: (change) => setState(change),
                  ),
                if (step == 3)
                  CqProcessingContent(
                    count: pages.length,
                    complete: complete,
                    onAdvance: () => setState(() => complete = true),
                    onView: () => setState(() {
                      readOnly = true;
                      step = 2;
                    }),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: step == 3 || readOnly
            ? null
            : SafeArea(
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppButton(
                        expand: true,
                        label: step == 0
                            ? (started
                                  ? 'Finish writing & add sheets'
                                  : 'Start CQ exam')
                            : step == 1
                            ? 'Review ${pages.length} sample pages'
                            : 'Submit demo for evaluation',
                        onPressed: step == 0
                            ? (started ? finish : start)
                            : pages.isEmpty
                            ? null
                            : () => setState(() => step++),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
