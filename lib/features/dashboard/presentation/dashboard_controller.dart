import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_kpi_model.dart';

class DashboardState {
  final bool isLoading;
  final DashboardKpiModel? kpi;
  final String? errorMessage;
  final bool isOffline;

  const DashboardState({
    this.isLoading = false,
    this.kpi,
    this.errorMessage,
    this.isOffline = false,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardKpiModel? kpi,
    String? errorMessage,
    bool? isOffline,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      kpi: kpi ?? this.kpi,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardController(this._repository) : super(const DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard({bool isRefresh = false}) async {
    if (!isRefresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final data = await _repository.fetchDashboardData();
      state = state.copyWith(isLoading: false, kpi: data, errorMessage: null, isOffline: false);
    } catch (e) {
      if (state.kpi != null) {
        // Mode hors ligne avec données précédentes conservées
        state = state.copyWith(isLoading: false, isOffline: true);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => DashboardRepository());

final dashboardControllerProvider = StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardController(repository);
});
