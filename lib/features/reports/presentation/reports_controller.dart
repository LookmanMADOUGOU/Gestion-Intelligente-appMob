import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reports_repository.dart';
import '../domain/prediction_model.dart';
import '../domain/reports_model.dart';

class ReportsState {
  final bool isLoading;
  final ReportsSummaryModel? summary;
  final SalesTrendReportModel? trend;
  final DecisionSupportSummaryModel? decisionSupport;
  final String? filterRisk;
  final String searchQuery;
  final String? errorMessage;

  const ReportsState({
    this.isLoading = false,
    this.summary,
    this.trend,
    this.decisionSupport,
    this.filterRisk,
    this.searchQuery = '',
    this.errorMessage,
  });

  ReportsState copyWith({
    bool? isLoading,
    ReportsSummaryModel? summary,
    SalesTrendReportModel? trend,
    DecisionSupportSummaryModel? decisionSupport,
    String? filterRisk,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      trend: trend ?? this.trend,
      decisionSupport: decisionSupport ?? this.decisionSupport,
      filterRisk: filterRisk ?? this.filterRisk,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ReportsController extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;

  ReportsController(this._repository) : super(const ReportsState()) {
    loadAll();
  }

  Future<void> loadAll({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summaryFuture = _repository.getSummary();
      final trendFuture = _repository.getSalesTrend(days: 14);
      final decisionFuture = _repository.getDecisionSupport(query: state.searchQuery);

      final results = await Future.wait([summaryFuture, trendFuture, decisionFuture]);

      state = state.copyWith(
        isLoading: false,
        summary: results[0] as ReportsSummaryModel,
        trend: results[1] as SalesTrendReportModel,
        decisionSupport: results[2] as DecisionSupportSummaryModel,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilterRisk(String? risk) {
    if (state.filterRisk == risk) {
      state = state.copyWith(filterRisk: null);
    } else {
      state = state.copyWith(filterRisk: risk);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadAll();
  }
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) => ReportsRepository());

final reportsControllerProvider = StateNotifierProvider<ReportsController, ReportsState>((ref) {
  final repo = ref.watch(reportsRepositoryProvider);
  return ReportsController(repo);
});
