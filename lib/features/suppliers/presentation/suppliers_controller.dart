import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supplier_repository.dart';
import '../domain/supplier_model.dart';

class SuppliersState {
  final bool isLoading;
  final List<SupplierModel> suppliers;
  final String searchQuery;
  final String? errorMessage;

  const SuppliersState({
    this.isLoading = false,
    this.suppliers = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  SuppliersState copyWith({
    bool? isLoading,
    List<SupplierModel>? suppliers,
    String? searchQuery,
    String? errorMessage,
  }) {
    return SuppliersState(
      isLoading: isLoading ?? this.isLoading,
      suppliers: suppliers ?? this.suppliers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class SuppliersController extends StateNotifier<SuppliersState> {
  final SupplierRepository _repository;

  SuppliersController(this._repository) : super(const SuppliersState()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getSuppliers(search: state.searchQuery);
      state = state.copyWith(isLoading: false, suppliers: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadSuppliers();
  }
}

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) => SupplierRepository());

final suppliersControllerProvider = StateNotifierProvider<SuppliersController, SuppliersState>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return SuppliersController(repo);
});
