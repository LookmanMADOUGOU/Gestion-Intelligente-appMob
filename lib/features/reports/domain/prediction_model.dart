class PredictionItemModel {
  final int produitId;
  final String produitNom;
  final String produitReference;
  final int stockActuel;
  final int seuilAlerte;
  final int stockMaximum;
  final double consoMoyenne;
  final String tendance;
  final double? stockoutDays;
  final String niveauRisque;
  final String labelRisque;
  final String badgeColor;
  final String recommandation;
  final bool actionRequise;
  final double safetyStock;
  final double rop;
  final int leadTimeDays;
  final bool isDormant;
  final int qteRecommandee;
  final double budgetEstime;
  final double prixAchat;

  PredictionItemModel({
    required this.produitId,
    required this.produitNom,
    required this.produitReference,
    required this.stockActuel,
    required this.seuilAlerte,
    required this.stockMaximum,
    required this.consoMoyenne,
    required this.tendance,
    this.stockoutDays,
    required this.niveauRisque,
    required this.labelRisque,
    required this.badgeColor,
    required this.recommandation,
    required this.actionRequise,
    required this.safetyStock,
    required this.rop,
    required this.leadTimeDays,
    required this.isDormant,
    required this.qteRecommandee,
    required this.budgetEstime,
    required this.prixAchat,
  });

  bool get isCritical => niveauRisque == 'CRITIQUE';
  bool get isHighRisk => niveauRisque == 'ELEVE';
  bool get isOverstock => niveauRisque == 'SURSTOCK';

  factory PredictionItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return PredictionItemModel(
      produitId: json['produit_id'] as int? ?? 0,
      produitNom: json['produit_nom'] as String? ?? '',
      produitReference: json['produit_reference'] as String? ?? '',
      stockActuel: json['stock_actuel'] as int? ?? 0,
      seuilAlerte: json['seuil_alerte'] as int? ?? 0,
      stockMaximum: json['stock_maximum'] as int? ?? 0,
      consoMoyenne: parseDouble(json['conso_moyenne']),
      tendance: json['tendance'] as String? ?? 'STABLE',
      stockoutDays: json['stockout_days'] != null ? parseDouble(json['stockout_days']) : null,
      niveauRisque: json['niveau_risque'] as String? ?? 'FAIBLE',
      labelRisque: json['label_risque'] as String? ?? 'Sécurisé',
      badgeColor: json['badge_color'] as String? ?? 'gray',
      recommandation: json['recommandation'] as String? ?? '',
      actionRequise: json['action_requise'] as bool? ?? false,
      safetyStock: parseDouble(json['safety_stock']),
      rop: parseDouble(json['rop']),
      leadTimeDays: json['lead_time_days'] as int? ?? 5,
      isDormant: json['is_dormant'] as bool? ?? false,
      qteRecommandee: json['qte_recommandee'] as int? ?? 0,
      budgetEstime: parseDouble(json['budget_estime']),
      prixAchat: parseDouble(json['prix_achat']),
    );
  }
}

class DecisionSupportSummaryModel {
  final int totalProduits;
  final int nbCritique;
  final int nbEleve;
  final int nbDormant;
  final int nbSurstock;
  final int nbSecurise;
  final double budgetTotalReappro;
  final List<PredictionItemModel> items;

  DecisionSupportSummaryModel({
    required this.totalProduits,
    required this.nbCritique,
    required this.nbEleve,
    required this.nbDormant,
    required this.nbSurstock,
    required this.nbSecurise,
    required this.budgetTotalReappro,
    required this.items,
  });

  factory DecisionSupportSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];
    return DecisionSupportSummaryModel(
      totalProduits: json['total_produits'] as int? ?? 0,
      nbCritique: json['nb_critique'] as int? ?? 0,
      nbEleve: json['nb_eleve'] as int? ?? 0,
      nbDormant: json['nb_dormant'] as int? ?? 0,
      nbSurstock: json['nb_surstock'] as int? ?? 0,
      nbSecurise: json['nb_securise'] as int? ?? 0,
      budgetTotalReappro: parseDouble(json['budget_total_reappro']),
      items: rawItems.map((e) => PredictionItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
