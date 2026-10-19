class PurchaseModel {
  final int id;
  final int produitId;
  final String produitNom;
  final int quantite;
  final String fournisseur;
  final int? fournisseurFk;
  final String? fournisseurNom;
  final double coutUnitaire;
  final String statut;
  final String? notes;
  final DateTime dateApprovisionnement;

  PurchaseModel({
    required this.id,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.fournisseur,
    this.fournisseurFk,
    this.fournisseurNom,
    required this.coutUnitaire,
    this.statut = 'RECU',
    this.notes,
    required this.dateApprovisionnement,
  });

  double get coutTotal => quantite * coutUnitaire;

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return PurchaseModel(
      id: json['id'] as int? ?? 0,
      produitId: json['produit'] as int? ?? 0,
      produitNom: json['produit_nom'] as String? ?? 'Produit #${json['produit']}',
      quantite: json['quantite'] as int? ?? 0,
      fournisseur: json['fournisseur'] as String? ?? '',
      fournisseurFk: json['fournisseur_fk'] as int?,
      fournisseurNom: json['fournisseur_nom'] as String?,
      coutUnitaire: parseDouble(json['cout_unitaire']),
      statut: json['statut'] as String? ?? 'RECU',
      notes: json['notes'] as String?,
      dateApprovisionnement: DateTime.tryParse(json['date_approvisionnement'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produit': produitId,
      'quantite': quantite,
      'fournisseur': fournisseur,
      if (fournisseurFk != null) 'fournisseur_fk': fournisseurFk,
      'cout_unitaire': coutUnitaire,
      'statut': statut,
      if (notes != null) 'notes': notes,
    };
  }
}
