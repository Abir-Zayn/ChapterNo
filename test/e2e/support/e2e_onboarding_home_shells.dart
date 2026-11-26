// Harness shell routes for /onboarding and /home used until Wave 4 merges
// real OnboardingPage and fixes the 32 pre-existing Home widget errors.
// Preserves form inputs on failure and excludes Foundation/Standard modes.
import 'e2e_onboarding_home_shells_imports.dart';

class E2eOnboardingShellPage extends StatefulWidget {
  const E2eOnboardingShellPage({
    super.key,
    required this.profileRepository,
    required this.curriculum,
    required this.onCompleted,
  });

  final FakeProfileRepository profileRepository;
  final FakeCurriculumCatalogue curriculum;
  final VoidCallback onCompleted;

  @override
  State<E2eOnboardingShellPage> createState() => _E2eOnboardingShellPageState();
}

class _E2eOnboardingShellPageState extends State<E2eOnboardingShellPage> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  String _batch = 'SSC 2027';
  String _boardId = 'dhaka';
  String _group = 'Science';
  String _pace = 'Standard';
  bool _submitting = false;
  List<E2eBoard> _boards = const [];

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    final res = await widget.curriculum.getEducationBoards();
    if (!mounted) return;
    res.fold((_) {}, (items) => setState(() => _boards = items));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    widget.profileRepository.pendingUsername = _usernameCtrl.text.trim();
    final draft = OnboardingDraft(
      displayName: _nameCtrl.text,
      batchYear: int.parse(_batch.split(' ').last),
      // shortcut: board code rides in name until Wave 4 swaps the real picker.
      board: OnboardingBoard(
        id: _boards.indexWhere((b) => b.id == _boardId) + 1,
        name: _boardId,
      ),
      academicGroup: switch (_group) {
        'Business Studies' => 'business_studies',
        'Humanities' => 'humanities',
        _ => 'science',
      },
      learningPace: switch (_pace) {
        'Casual' => 'casual',
        'Intensive' => 'intensive',
        _ => 'standard',
      },
    );
    final res = await widget.profileRepository.completeOnboarding(draft);
    if (!mounted) return;
    setState(() => _submitting = false);
    res.fold(
      (f) => AppSnackBar.show(context, f.message, type: AppSnackBarType.error),
      (_) => widget.onCompleted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.title('Complete your profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('onboarding_name_field'),
                controller: _nameCtrl,
                enabled: !_submitting,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                key: const Key('onboarding_username_field'),
                controller: _usernameCtrl,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Username (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final b in const ['SSC 2027', 'SSC 2028'])
                    ChoiceChip(
                      label: Text(b),
                      selected: _batch == b,
                      onSelected: _submitting
                          ? null
                          : (_) => setState(() => _batch = b),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final g in const [
                    'Science',
                    'Business Studies',
                    'Humanities',
                  ])
                    ChoiceChip(
                      label: Text(g),
                      selected: _group == g,
                      onSelected: _submitting
                          ? null
                          : (_) => setState(() => _group = g),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final p in const ['Casual', 'Standard', 'Intensive'])
                    ChoiceChip(
                      label: Text(p),
                      selected: _pace == p,
                      onSelected: _submitting
                          ? null
                          : (_) => setState(() => _pace = p),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final board in _boards)
                    ChoiceChip(
                      label: Text('${board.nameEn} (${board.nameBn})'),
                      selected: _boardId == board.id,
                      onSelected: _submitting
                          ? null
                          : (_) => setState(() => _boardId = board.id),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Save and continue',
                expand: true,
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class E2eHomeShellPage extends StatelessWidget {
  const E2eHomeShellPage({
    super.key,
    required this.onOpenProfile,
    required this.onOpenAnalytics,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText.title('Home')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.headline('Your study dashboard'),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Profile',
                expand: true,
                onPressed: onOpenProfile,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Learning Analytics',
                expand: true,
                variant: AppButtonVariant.outline,
                onPressed: onOpenAnalytics,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Settings',
                expand: true,
                variant: AppButtonVariant.outline,
                onPressed: onOpenSettings,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Sign out',
                expand: true,
                variant: AppButtonVariant.danger,
                onPressed: onSignOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
