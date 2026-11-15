// Immutable state hierarchy for the Settings screen.
// Holds profile summary, current settings, saving flags, and sign-out outcome.
import 'cubits_imports.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.profile,
    required this.settings,
    this.isSaving = false,
    this.isSigningOut = false,
    this.signedOut = false,
    this.actionError,
  });

  final StudentProfile profile;
  final AppSettings settings;
  final bool isSaving;
  final bool isSigningOut;
  final bool signedOut;
  final String? actionError;

  SettingsLoaded copyWith({
    StudentProfile? profile,
    AppSettings? settings,
    bool? isSaving,
    bool? isSigningOut,
    bool? signedOut,
    String? actionError,
    bool clearActionError = false,
  }) {
    return SettingsLoaded(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      signedOut: signedOut ?? this.signedOut,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
    profile,
    settings,
    isSaving,
    isSigningOut,
    signedOut,
    actionError,
  ];
}

final class SettingsError extends SettingsState {
  const SettingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
