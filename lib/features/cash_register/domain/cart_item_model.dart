import '../../products/domain/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  double customUnitPrice;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    double? unitPrice,
  }) : customUnitPrice = unitPrice ?? product.prixUnitaire;

  double get totalPrice => quantity * customUnitPrice;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    double? customUnitPrice,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: customUnitPrice ?? this.customUnitPrice,
    );
  }

  Map<String, dynamic> toApiPayload() {
    return {
      'produit_id': product.id,
      'quantite': quantity,
      'prix_unitaire': customUnitPrice,
    };
  }
}

class ReceiptModel {
  final String referenceTicket;
  final DateTime dateVente;
  final double totalNet;
  final String modePaiement;
  final String clientNom;
  final int nombreArticles;
  final List<CartItemModel> items;

  ReceiptModel({
    required this.referenceTicket,
    required this.dateVente,
    required this.totalNet,
    required this.modePaiement,
    required this.clientNom,
    required this.nombreArticles,
    required this.items,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json, List<CartItemModel> items) {
    return ReceiptModel(
      referenceTicket: json['reference_ticket'] as String? ?? 'TCK-000',
      dateVente: DateTime.tryParse(json['date_vente'] as String? ?? '') ?? DateTime.now(),
      totalNet: (json['total_net'] as num?)?.toDouble() ?? 0.0,
      modePaiement: json['mode_paiement'] as String? ?? 'ESPECES',
      clientNom: json['client_nom'] as String? ?? 'Client Passant',
      nombreArticles: json['nombre_articles'] as int? ?? items.length,
      items: items,
    );
  }
}
