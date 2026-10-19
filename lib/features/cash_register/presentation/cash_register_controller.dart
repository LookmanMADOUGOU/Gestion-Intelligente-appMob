import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/domain/customer_model.dart';
import '../../products/domain/product_model.dart';
import '../data/cash_register_repository.dart';
import '../domain/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final CustomerModel? selectedClient;
  final String modePaiement; // 'ESPECES', 'CARTE', 'MOBILE_MONEY', 'CHEQUE', 'CREDIT'
  final double remiseGlobale;
  final bool isLoading;
  final String? errorMessage;
  final ReceiptModel? lastReceipt;

  const CartState({
    this.items = const [],
    this.selectedClient,
    this.modePaiement = 'ESPECES',
    this.remiseGlobale = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.lastReceipt,
  });

  int get totalArticlesCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalBrut => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalNet {
    final net = totalBrut - remiseGlobale;
    return net > 0 ? net : 0.0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    CustomerModel? selectedClient,
    bool clearClient = false,
    String? modePaiement,
    double? remiseGlobale,
    bool? isLoading,
    String? errorMessage,
    ReceiptModel? lastReceipt,
    bool clearReceipt = false,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedClient: clearClient ? null : (selectedClient ?? this.selectedClient),
      modePaiement: modePaiement ?? this.modePaiement,
      remiseGlobale: remiseGlobale ?? this.remiseGlobale,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastReceipt: clearReceipt ? null : (lastReceipt ?? this.lastReceipt),
    );
  }
}

class CartController extends StateNotifier<CartState> {
  final CashRegisterRepository _repository;

  CartController(this._repository) : super(const CartState());

  void addItem(ProductModel product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final current = state.items[existingIndex];
      // Vérifier le stock disponible
      if (current.quantity + 1 > product.stockActuel) return;

      final updated = List<CartItemModel>.from(state.items);
      updated[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      if (product.stockActuel <= 0) return;
      state = state.copyWith(items: [
        ...state.items,
        CartItemModel(product: product, quantity: 1),
      ]);
    }
  }

  void updateQuantity(int productId, int delta) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == productId);
    if (existingIndex < 0) return;

    final current = state.items[existingIndex];
    final newQte = current.quantity + delta;

    final updated = List<CartItemModel>.from(state.items);
    if (newQte <= 0) {
      updated.removeAt(existingIndex);
    } else {
      if (newQte > current.product.stockActuel) return; // Limite stock
      updated[existingIndex] = current.copyWith(quantity: newQte);
    }
    state = state.copyWith(items: updated);
  }

  void removeItem(int productId) {
    final updated = state.items.where((i) => i.product.id != productId).toList();
    state = state.copyWith(items: updated);
  }

  void setClient(CustomerModel? client) {
    state = state.copyWith(selectedClient: client, clearClient: client == null);
  }

  void setModePaiement(String mode) {
    state = state.copyWith(modePaiement: mode);
  }

  void setRemiseGlobale(double remise) {
    state = state.copyWith(remiseGlobale: remise);
  }

  void clearCart() {
    state = state.copyWith(
      items: [],
      clearClient: true,
      remiseGlobale: 0.0,
      modePaiement: 'ESPECES',
      errorMessage: null,
      clearReceipt: true,
    );
  }

  Future<ReceiptModel?> checkout({String notes = ''}) async {
    if (state.items.isEmpty) return null;

    if (state.modePaiement == 'CREDIT' && state.selectedClient == null) {
      state = state.copyWith(errorMessage: "Une vente à crédit exige obligatoirement un client valide.");
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final receipt = await _repository.checkout(
        items: state.items,
        clientId: state.selectedClient?.id,
        modePaiement: state.modePaiement,
        remiseGlobale: state.remiseGlobale,
        notes: notes,
      );

      state = state.copyWith(
        items: [],
        clearClient: true,
        remiseGlobale: 0.0,
        isLoading: false,
        lastReceipt: receipt,
      );
      return receipt;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }
}

final cashRegisterRepositoryProvider = Provider<CashRegisterRepository>((ref) => CashRegisterRepository());

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  final repo = ref.watch(cashRegisterRepositoryProvider);
  return CartController(repo);
});
