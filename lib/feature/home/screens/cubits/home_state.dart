// Immutable state definitions for the Student Home Dashboard flow.
// Emits distinct states for initial setup, loading, content loaded, and errors.
import 'cubits_imports.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded({required this.dashboard});

  final StudentDashboard dashboard;

  @override
  List<Object?> get props => [dashboard];
}

final class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
