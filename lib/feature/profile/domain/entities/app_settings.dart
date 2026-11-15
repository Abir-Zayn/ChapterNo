// Immutable domain entity and enums for student app settings.
// Tracks notification, feedback, learning track, language, and theme prefs.
import 'entities_imports.dart';

enum LearningTrack {
  standardSsc('Standard SSC'),
  acceleratedRevision('Accelerated Revision'),
  examSprint('Board Exam Sprint');

  const LearningTrack(this.label);
  final String label;
}

enum AppLanguage {
  english('English'),
  bangla('Bangla (Coming soon)');

  const AppLanguage(this.label);
  final String label;
}

class AppSettings extends Equatable {
  const AppSettings({
    required this.notificationsEnabled,
    required this.soundEffectsEnabled,
    required this.hapticsEnabled,
    required this.learningTrack,
    required this.language,
    required this.darkModeEnabled,
  });

  final bool notificationsEnabled;
  final bool soundEffectsEnabled;
  final bool hapticsEnabled;
  final LearningTrack learningTrack;
  final AppLanguage language;
  final bool darkModeEnabled;

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEffectsEnabled,
    bool? hapticsEnabled,
    LearningTrack? learningTrack,
    AppLanguage? language,
    bool? darkModeEnabled,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      learningTrack: learningTrack ?? this.learningTrack,
      language: language ?? this.language,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    soundEffectsEnabled,
    hapticsEnabled,
    learningTrack,
    language,
    darkModeEnabled,
  ];
}
