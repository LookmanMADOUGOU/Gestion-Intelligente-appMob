import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../domain/product_model.dart';

class ProductsState {
  final bool isLoading;
  final List<ProductModel> products;
  final int totalCount;
  final int currentPage;
  final bool hasNext;
  final String searchQuery;
  final bool? filterRupture;
  final int? filterCategory;
  final String? errorMessage;

  const ProductsState({
    this.isLoading = false,
    this.products = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.hasNext = false,
    this.searchQuery = '',
    this.filterRupture,
    this.filterCategory,
    this.errorMessage,
  });

  ProductsState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    int? totalCount,
    int? currentPage,
    bool? hasNext,
    String? searchQuery,
    bool? filterRupture,
    int? filterCategory,
    String? errorMessage,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      searchQuery: searchQuery ?? this.searchQuery,
      filterRupture: filterRupture,
      filterCategory: filterCategory,
      errorMessage: errorMessage,
    );
  }
}

class ProductsController extends StateNotifier<ProductsState> {
  final ProductRepository _repository;

  ProductsController(this._repository) : super(const ProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.getProducts(
        page: 1,
        search: state.searchQuery,
        isRupture: state.filterRupture,
        categoryId: state.filterCategory,
      );
      state = state.copyWith(
        isLoading: false,
        products: result.products,
        totalCount: result.count,
        currentPage: 1,
        hasNext: result.hasNext,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProducts();
  }

  void toggleRuptureFilter(bool? isRupture) {
    state = state.copyWith(filterRupture: isRupture);
    loadProducts();
  }

  Future<void> loadNextPage() async {
    if (!state.hasNext || state.isLoading) return;
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getProducts(
        page: nextPage,
        search: state.searchQuery,
        isRupture: state.filterRupture,
        categoryId: state.filterCategory,
      );
      state = state.copyWith(
        products: [...state.products, ...result.products],
        currentPage: nextPage,
        hasNext: result.hasNext,
      );
    } catch (_) {}
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository());

final productsControllerProvider = StateNotifierProvider<ProductsController, ProductsState>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductsController(repo);
});
