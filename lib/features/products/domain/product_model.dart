class ProductModel {
  final int id;
  final String nom;
  final String reference;
  final String? sku;
  final String? codeBarres;
  final String? description;
  final String unite;
  final int stockActuel;
  final int seuilAlerte;
  final int stockMaximum;
  final String statutStock;
  final double prixUnitaire;
  final double prixAchat;
  final double margeUnitaire;
  final double tauxMarge;
  final double valeurStockAchat;
  final double valeurStockVente;
  final String statut;
  final bool rupture;
  final dynamic predictionMl;
  final dynamic predictionRupture;

  ProductModel({
    required this.id,
    required this.nom,
    required this.reference,
    this.sku,
    this.codeBarres,
    this.description,
    this.unite = 'unité',
    required this.stockActuel,
    required this.seuilAlerte,
    this.stockMaximum = 100,
    required this.statutStock,
    required this.prixUnitaire,
    required this.prixAchat,
    required this.margeUnitaire,
    required this.tauxMarge,
    required this.valeurStockAchat,
    required this.valeurStockVente,
    this.statut = 'ACTIF',
    required this.rupture,
    this.predictionMl,
    this.predictionRupture,
  });

  bool get isOutOfStock => stockActuel <= 0;
  bool get isLowStock => stockActuel > 0 && stockActuel <= seuilAlerte;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return ProductModel(
      id: parseInt(json['id']),
      nom: json['nom'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      sku: json['sku'] as String?,
      codeBarres: json['code_barres'] as String?,
      description: json['description'] as String?,
      unite: json['unite'] as String? ?? 'unité',
      stockActuel: parseInt(json['stock_actuel']),
      seuilAlerte: parseInt(json['seuil_alerte']),
      stockMaximum: parseInt(json['stock_maximum']),
      statutStock: json['statut_stock'] as String? ?? 'STOCK NORMAL',
      prixUnitaire: parseDouble(json['prix_unitaire']),
      prixAchat: parseDouble(json['prix_achat']),
      margeUnitaire: parseDouble(json['marge_unitaire']),
      tauxMarge: parseDouble(json['taux_marge']),
      valeurStockAchat: parseDouble(json['valeur_stock_achat']),
      valeurStockVente: parseDouble(json['valeur_stock_vente']),
      statut: json['statut'] as String? ?? 'ACTIF',
      rupture: json['rupture'] as bool? ?? false,
      predictionMl: json['prediction_ml'],
      predictionRupture: json['prediction_rupture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'reference': reference,
      'sku': sku,
      'code_barres': codeBarres,
      'description': description,
      'unite': unite,
      'stock_actuel': stockActuel,
      'seuil_alerte': seuilAlerte,
      'stock_maximum': stockMaximum,
      'statut_stock': statutStock,
      'prix_unitaire': prixUnitaire,
      'prix_achat': prixAchat,
      'marge_unitaire': margeUnitaire,
      'taux_marge': tauxMarge,
      'valeur_stock_achat': valeurStockAchat,
      'valeur_stock_vente': valeurStockVente,
      'statut': statut,
      'rupture': rupture,
      'prediction_ml': predictionMl,
      'prediction_rupture': predictionRupture,
    };
  }
}
