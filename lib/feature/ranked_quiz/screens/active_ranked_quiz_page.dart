// Live ranked quiz: countdown timer, stepped progress, question card,
// selectable options and forfeit-on-exit confirmation. Answers stay in
// local widget state for this UI preview; nothing is scored or saved.
import 'ranked_quiz_imports.dart';

class ActiveRankedQuizPage extends StatefulWidget {
  const ActiveRankedQuizPage({
    super.key,
    required this.onFinished,
    required this.onForfeit,
  });

  final VoidCallback onFinished;
  final VoidCallback onForfeit;

  @override
  State<ActiveRankedQuizPage> createState() => _ActiveRankedQuizPageState();
}

class _ActiveRankedQuizPageState extends State<ActiveRankedQuizPage> {
  final _questions = RankedQuizFixtures.questions;
  late final List<int?> _answers = List.filled(_questions.length, null);
  final Set<int> _bookmarked = {};
  int _index = 0;
  int _remaining = RankedQuizFixtures.timeLimitSeconds;
  Timer? _timer;

  bool get _isLast => _index == _questions.length - 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        widget.onFinished();
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _confirmExit() async {
    final forfeit = await AppConfirmDialog.show(
      context,
      title: 'Forfeit this Ranked Quiz?',
      message:
          'Exiting now will forfeit this attempt. Your score will be '
          'recorded as incomplete.',
      confirmLabel: 'Forfeit Attempt',
      cancelLabel: 'Stay & Continue',
      isDestructive: true,
    );
    if (!forfeit || !mounted) return;
    _timer?.cancel();
    widget.onForfeit();
  }

  void _next() {
    if (_isLast) {
      _timer?.cancel();
      widget.onFinished();
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final total = _questions.length;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: AppSpacing.screen,
                      children: [
                        RankedTopBar(
                          eyebrow: 'Ranked Arena',
                          title: '${RankedQuizFixtures.subject} · Mixed MCQ',
                          leadingIcon: PhosphorIconsRegular.x,
                          leadingTooltip: 'Exit quiz',
                          onLeading: _confirmExit,
                          trailing: RankedPill(
                            label: _clock,
                            icon: PhosphorIconsRegular.timer,
                            background: context.primarySoft,
                            foreground: context.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _ProgressCard(index: _index, total: total),
                        const SizedBox(height: AppSpacing.md),
                        QuizQuestionCard(
                          prompt: question.prompt,
                          note: question.note,
                          bookmarked: _bookmarked.contains(_index),
                          onToggleBookmark: () => setState(() {
                            if (!_bookmarked.remove(_index)) {
                              _bookmarked.add(_index);
                            }
                          }),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (var i = 0; i < question.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: QuizOptionTile(
                              letter: String.fromCharCode(65 + i),
                              label: question.options[i],
                              selected: _answers[_index] == i,
                              onTap: () => setState(() => _answers[_index] = i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  QuizBottomControls(
                    index: _index,
                    total: total,
                    isLast: _isLast,
                    onPrevious: _index == 0
                        ? null
                        : () => setState(() => _index--),
                    onNext: _next,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              const Flexible(
                child: RankedPill(
                  label: 'Ranked SSC Exam',
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText.label(
                  'Question ${index + 1} of $total',
                  color: context.primary,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AttemptPips(
            filled: index + 1,
            total: total,
            current: index,
            height: 6,
          ),
        ],
      ),
    );
  }
}
