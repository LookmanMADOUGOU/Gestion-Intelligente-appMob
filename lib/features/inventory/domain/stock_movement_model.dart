class StockMovementModel {
  final int id;
  final int produitId;
  final String produitNom;
  final int quantite;
  final String typeMouvement;
  final int stockAvant;
  final int stockApres;
  final DateTime dateMouvement;
  final String utilisateurUsername;
  final String reference;
  final String? commentaire;

  StockMovementModel({
    required this.id,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.typeMouvement,
    required this.stockAvant,
    required this.stockApres,
    required this.dateMouvement,
    required this.utilisateurUsername,
    required this.reference,
    this.commentaire,
  });

  bool get isEntry => typeMouvement == 'ENTREE' || typeMouvement == 'ACHAT' || typeMouvement == 'RETOUR' || stockApres > stockAvant;

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as int? ?? 0,
      produitId: json['produit'] as int? ?? 0,
      produitNom: json['produit_nom'] as String? ?? 'Produit',
      quantite: json['quantite'] as int? ?? 0,
      typeMouvement: json['type_mouvement'] as String? ?? 'AJUSTEMENT',
      stockAvant: json['stock_avant'] as int? ?? 0,
      stockApres: json['stock_apres'] as int? ?? 0,
      dateMouvement: DateTime.tryParse(json['date_mouvement'] as String? ?? '') ?? DateTime.now(),
      utilisateurUsername: json['utilisateur_username'] as String? ?? 'Système',
      reference: json['reference'] as String? ?? '',
      commentaire: json['commentaire'] as String?,
    );
  }
}
