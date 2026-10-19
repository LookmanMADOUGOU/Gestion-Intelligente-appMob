class SupplierModel {
  final int id;
  final String nom;
  final String? telephone;
  final String? email;
  final String? adresse;
  final double detteFournisseur;
  final int totalApprovisionnementsCount;
  final double totalAchatsMontant;
  final DateTime dateCreation;

  SupplierModel({
    required this.id,
    required this.nom,
    this.telephone,
    this.email,
    this.adresse,
    required this.detteFournisseur,
    this.totalApprovisionnementsCount = 0,
    this.totalAchatsMontant = 0.0,
    required this.dateCreation,
  });

  bool get hasDebt => detteFournisseur > 0;

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return SupplierModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      detteFournisseur: parseDouble(json['dette_fournisseur']),
      totalApprovisionnementsCount: json['total_approvisionnements_count'] as int? ?? 0,
      totalAchatsMontant: parseDouble(json['total_achats_montant']),
      dateCreation: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
