class CustomerModel {
  final int id;
  final String nom;
  final String? telephone;
  final String? email;
  final String? adresse;
  final double soldeCredit;
  final int totalAchatsCount;
  final double totalDepense;
  final DateTime dateCreation;

  CustomerModel({
    required this.id,
    required this.nom,
    this.telephone,
    this.email,
    this.adresse,
    required this.soldeCredit,
    this.totalAchatsCount = 0,
    this.totalDepense = 0.0,
    required this.dateCreation,
  });

  bool get hasCreditDebt => soldeCredit > 0;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return CustomerModel(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      soldeCredit: parseDouble(json['solde_credit']),
      totalAchatsCount: json['total_achats_count'] as int? ?? 0,
      totalDepense: parseDouble(json['total_depense']),
      dateCreation: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'solde_credit': soldeCredit,
    };
  }
}
