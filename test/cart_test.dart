import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tech_mobile/features/cash_register/domain/cart_item_model.dart';
import 'package:smart_tech_mobile/features/products/domain/product_model.dart';

void main() {
  group('Panier Caisse POS (CartItemModel) Tests', () {
    final mockProduct = ProductModel(
      id: 1,
      nom: 'Ordinateur Portable Pro',
      reference: 'PC-PRO-001',
      stockActuel: 10,
      seuilAlerte: 2,
      stockMaximum: 50,
      statutStock: 'STOCK NORMAL',
      prixAchat: 200000.0,
      prixUnitaire: 250000.0,
      margeUnitaire: 50000.0,
      tauxMarge: 25.0,
      valeurStockAchat: 2000000.0,
      valeurStockVente: 2500000.0,
      rupture: false,
    );

    test('Calcul du total du panier', () {
      final cartItem = CartItemModel(
        product: mockProduct,
        quantity: 3,
        unitPrice: 250000.0,
      );

      expect(cartItem.totalPrice, equals(750000.0));
      expect(cartItem.quantity, equals(3));
    });

    test('Incrémentation et décrémentation des quantités', () {
      var cartItem = CartItemModel(product: mockProduct, quantity: 1);
      expect(cartItem.quantity, equals(1));

      cartItem = cartItem.copyWith(quantity: cartItem.quantity + 1);
      expect(cartItem.quantity, equals(2));
      expect(cartItem.totalPrice, equals(500000.0));

      cartItem = cartItem.copyWith(quantity: cartItem.quantity - 1);
      expect(cartItem.quantity, equals(1));
    });

    test('Conversion vers payload API pour checkout DRF', () {
      final cartItem = CartItemModel(
        product: mockProduct,
        quantity: 4,
        unitPrice: 250000.0,
      );

      final payload = cartItem.toApiPayload();
      expect(payload['produit_id'], equals(1));
      expect(payload['quantite'], equals(4));
      expect(payload['prix_unitaire'], equals(250000.0));
    });
  });
}
