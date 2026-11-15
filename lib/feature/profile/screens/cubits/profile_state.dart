// Immutable state hierarchy for the Student Profile Dashboard screen.
// Preserves loaded profile data during pace updates and recoverable errors.
import 'cubits_imports.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.profile,
    this.isUpdating = false,
    this.actionError,
  });

  final StudentProfile profile;
  final bool isUpdating;
  final String? actionError;

  ProfileLoaded copyWith({
    StudentProfile? profile,
    bool? isUpdating,
    String? actionError,
    bool clearActionError = false,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [profile, isUpdating, actionError];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
