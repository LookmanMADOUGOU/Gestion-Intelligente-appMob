import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customer_repository.dart';
import '../domain/customer_model.dart';

class CustomersState {
  final bool isLoading;
  final List<CustomerModel> customers;
  final String searchQuery;
  final String? errorMessage;

  const CustomersState({
    this.isLoading = false,
    this.customers = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  CustomersState copyWith({
    bool? isLoading,
    List<CustomerModel>? customers,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CustomersState(
      isLoading: isLoading ?? this.isLoading,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class CustomersController extends StateNotifier<CustomersState> {
  final CustomerRepository _repository;

  CustomersController(this._repository) : super(const CustomersState()) {
    loadCustomers();
  }

  Future<void> loadCustomers({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getCustomers(search: state.searchQuery);
      state = state.copyWith(isLoading: false, customers: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadCustomers();
  }
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) => CustomerRepository());

final customersControllerProvider = StateNotifierProvider<CustomersController, CustomersState>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomersController(repo);
});
