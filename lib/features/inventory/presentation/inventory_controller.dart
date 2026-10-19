import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_repository.dart';
import '../domain/stock_movement_model.dart';

class MovementsState {
  final bool isLoading;
  final List<StockMovementModel> movements;
  final String? filterType;
  final String? errorMessage;

  const MovementsState({
    this.isLoading = false,
    this.movements = const [],
    this.filterType,
    this.errorMessage,
  });

  MovementsState copyWith({
    bool? isLoading,
    List<StockMovementModel>? movements,
    String? filterType,
    String? errorMessage,
  }) {
    return MovementsState(
      isLoading: isLoading ?? this.isLoading,
      movements: movements ?? this.movements,
      filterType: filterType ?? this.filterType,
      errorMessage: errorMessage,
    );
  }
}

class MovementsController extends StateNotifier<MovementsState> {
  final InventoryRepository _repository;

  MovementsController(this._repository) : super(const MovementsState()) {
    loadMovements();
  }

  Future<void> loadMovements({int? productId, bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getMovements(
        productId: productId,
        typeMouvement: state.filterType,
      );
      state = state.copyWith(isLoading: false, movements: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilterType(String? type) {
    state = state.copyWith(filterType: type);
    loadMovements();
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => InventoryRepository());

final movementsControllerProvider = StateNotifierProvider<MovementsController, MovementsState>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return MovementsController(repo);
});
