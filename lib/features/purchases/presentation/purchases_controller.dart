import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/purchases_repository.dart';
import '../domain/purchase_model.dart';

class PurchasesState {
  final bool isLoading;
  final List<PurchaseModel> purchases;
  final String searchQuery;
  final String? errorMessage;

  const PurchasesState({
    this.isLoading = false,
    this.purchases = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  PurchasesState copyWith({
    bool? isLoading,
    List<PurchaseModel>? purchases,
    String? searchQuery,
    String? errorMessage,
  }) {
    return PurchasesState(
      isLoading: isLoading ?? this.isLoading,
      purchases: purchases ?? this.purchases,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class PurchasesController extends StateNotifier<PurchasesState> {
  final PurchasesRepository _repository;

  PurchasesController(this._repository) : super(const PurchasesState()) {
    loadPurchases();
  }

  Future<void> loadPurchases({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getPurchases(search: state.searchQuery);
      state = state.copyWith(isLoading: false, purchases: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadPurchases();
  }
}

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) => PurchasesRepository());

final purchasesControllerProvider = StateNotifierProvider<PurchasesController, PurchasesState>((ref) {
  final repo = ref.watch(purchasesRepositoryProvider);
  return PurchasesController(repo);
});
