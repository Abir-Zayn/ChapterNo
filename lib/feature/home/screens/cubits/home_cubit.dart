// Manages state and asynchronous transitions for the Student Home Dashboard.
// Loads dashboard metrics, handles refresh requests, and advances goals.
import 'cubits_imports.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this._homeRepository}) : super(const HomeInitial());

  final HomeRepository _homeRepository;

  Future<void> loadDashboard() async {
    emit(const HomeLoading());
    final result = await _homeRepository.getDashboard();
    if (isClosed) return;

    result.fold(
      (failure) => emit(HomeError(message: failure)),
      (dashboard) => emit(HomeLoaded(dashboard: dashboard)),
    );
  }

  Future<void> refreshDashboard() async {
    final result = await _homeRepository.getDashboard();
    if (isClosed) return;

    result.fold(
      (failure) => emit(HomeError(message: failure)),
      (dashboard) => emit(HomeLoaded(dashboard: dashboard)),
    );
  }

  Future<void> advanceDailyGoal() async {
    final result = await _homeRepository.incrementGoalProgress();
    if (isClosed) return;

    result.fold(
      (failure) => emit(HomeError(message: failure)),
      (dashboard) => emit(HomeLoaded(dashboard: dashboard)),
    );
  }
}
