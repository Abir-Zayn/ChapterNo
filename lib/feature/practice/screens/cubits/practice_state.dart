// State definitions for the Practice Dashboard screen.
// Encapsulates loading, loaded data, and error conditions using Equatable.
import 'cubits_imports.dart';

sealed class PracticeState extends Equatable {
  const PracticeState();

  @override
  List<Object?> get props => [];
}

class PracticeInitial extends PracticeState {
  const PracticeInitial();
}

class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

class PracticeLoaded extends PracticeState {
  const PracticeLoaded({required this.data});

  final PracticeDashboardData data;

  @override
  List<Object?> get props => [data];
}

class PracticeError extends PracticeState {
  const PracticeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
