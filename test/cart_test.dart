import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tech_mobile/features/cash_register/domain/cart_item_model.dart';
import 'package:smart_tech_mobile/features/products/domain/product_model.dart';

void main() {
  group('Panier Caisse POS (CartItemModel) Tests', () {
    final mockProduct = ProductModel(
      id: 1,
      nom: 'Ordinateur Portable Pro',
      reference: 'PC-PRO-001',
      categorie: 1,
      categorieNom: 'Informatique',
      prixAchat: 200000.0,
      prixUnitaire: 250000.0,
      stockActuel: 10,
      seuilAlerte: 2,
      stockMaximum: 50,
      dateCreation: DateTime.now(),
    );

    test('Calcul du sous-total sans remise', () {
      final cartItem = CartItemModel(
        product: mockProduct,
        quantite: 3,
        prixUnitaire: 250000.0,
        remise: 0.0,
      );

      expect(cartItem.sousTotalBrut, equals(750000.0));
      expect(cartItem.sousTotalNet, equals(750000.0));
      expect(cartItem.beneficeTotal, equals(150000.0)); // (250000 - 200000) * 3
    });

    test('Calcul du sous-total avec remise unitaire', () {
      final cartItem = CartItemModel(
        product: mockProduct,
        quantite: 2,
        prixUnitaire: 250000.0,
        remise: 10000.0,
      );

      expect(cartItem.sousTotalBrut, equals(500000.0));
      expect(cartItem.sousTotalNet, equals(480000.0)); // 500000 - (10000 * 2)
      expect(cartItem.beneficeTotal, equals(80000.0)); // 480000 - (200000 * 2)
    });

    test('Incrémentation et décrémentation des quantités', () {
      var cartItem = CartItemModel(product: mockProduct, quantite: 1);
      expect(cartItem.quantite, equals(1));

      cartItem = cartItem.copyWith(quantite: cartItem.quantite + 1);
      expect(cartItem.quantite, equals(2));
      expect(cartItem.sousTotalNet, equals(500000.0));

      cartItem = cartItem.copyWith(quantite: cartItem.quantite - 1);
      expect(cartItem.quantite, equals(1));
    });

    test('Conversion vers JSON pour le checkout DRF', () {
      final cartItem = CartItemModel(
        product: mockProduct,
        quantite: 4,
        prixUnitaire: 250000.0,
        remise: 5000.0,
      );

      final json = cartItem.toJson();
      expect(json['produit_id'], equals(1));
      expect(json['quantite'], equals(4));
      expect(json['prix_unitaire'], equals(250000.0));
      expect(json['remise'], equals(5000.0));
    });
  });
}
