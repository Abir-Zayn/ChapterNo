// Domain entity for the onboarding draft and its selectable options.
// Holds validated field values before they persist to student_profiles.
import 'entities_imports.dart';

class OnboardingBoard extends Equatable {
  const OnboardingBoard({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class OnboardingOption extends Equatable {
  const OnboardingOption({required this.value, required this.label});

  /// Stored database value (for example 'science' or 'standard').
  final String value;

  /// Human-facing label shown in the UI.
  final String label;

  @override
  List<Object?> get props => [value, label];
}

class OnboardingDraft extends Equatable {
  const OnboardingDraft({
    required this.displayName,
    required this.batchYear,
    required this.board,
    required this.academicGroup,
    this.learningPace = 'standard',
  });

  /// SSC batch years offered on the onboarding form, in chip order.
  static const List<int> batchYears = [2026, 2027, 2028];

  static const List<OnboardingOption> academicGroupOptions = [
    OnboardingOption(value: 'science', label: 'Science'),
    OnboardingOption(value: 'business_studies', label: 'Business Studies'),
    OnboardingOption(value: 'humanities', label: 'Humanities'),
  ];

  static const List<OnboardingOption> learningPaceOptions = [
    OnboardingOption(value: 'casual', label: 'Casual'),
    OnboardingOption(value: 'standard', label: 'Standard'),
    OnboardingOption(value: 'intensive', label: 'Intensive'),
  ];

  /// Display-name rule: 2-60 characters after trimming.
  static String? validateDisplayName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < 2) return 'Enter at least 2 characters.';
    if (trimmed.length > 60) return 'Keep it under 60 characters.';
    return null;
  }

  /// Label for a stored learning-pace value; unknown values show as-is.
  static String labelForPace(String value) {
    for (final option in learningPaceOptions) {
      if (option.value == value) return option.label;
    }
    return value;
  }

  final String displayName;
  final int? batchYear;
  final OnboardingBoard? board;
  final String? academicGroup;
  final String learningPace;

  @override
  List<Object?> get props => [
    displayName,
    batchYear,
    board,
    academicGroup,
    learningPace,
  ];
}
