class AlerteModel {
  final int id;
  final int? produitId;
  final String produitNom;
  final String niveau;
  final String message;
  final bool estResolue;
  final DateTime dateCreation;
  final DateTime? dateResolution;

  AlerteModel({
    required this.id,
    this.produitId,
    required this.produitNom,
    required this.niveau,
    required this.message,
    required this.estResolue,
    required this.dateCreation,
    this.dateResolution,
  });

  bool get isCritical => niveau.toUpperCase() == 'CRITIQUE' || niveau.toUpperCase() == 'ROUGE';
  bool get isWarning => niveau.toUpperCase() == 'ATTENTION' || niveau.toUpperCase() == 'ORANGE';

  factory AlerteModel.fromJson(Map<String, dynamic> json) {
    return AlerteModel(
      id: json['id'] as int? ?? 0,
      produitId: json['produit'] as int?,
      produitNom: json['produit_nom'] as String? ?? 'Produit',
      niveau: json['niveau'] as String? ?? 'ATTENTION',
      message: json['message'] as String? ?? '',
      estResolue: json['est_resolue'] as bool? ?? false,
      dateCreation: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
      dateResolution: json['date_resolution'] != null ? DateTime.tryParse(json['date_resolution'] as String) : null,
    );
  }
}

class NotificationModel {
  final int id;
  final String titre;
  final String message;
  final String typeNotif;
  final bool lue;
  final DateTime dateCreation;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.typeNotif,
    required this.lue,
    required this.dateCreation,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? '',
      message: json['message'] as String? ?? '',
      typeNotif: json['type_notif'] as String? ?? 'INFO',
      lue: json['lue'] as bool? ?? false,
      dateCreation: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
      actionUrl: json['action_url'] as String?,
    );
  }
}
