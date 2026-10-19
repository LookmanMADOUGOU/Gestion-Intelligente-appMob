class ApiEndpoints {
  // Authentification & Session JWT
  static const String token = '/token/';
  static const String tokenRefresh = '/token/refresh/';
  static const String me = '/auth/me/';

  // Produits
  static const String produits = '/produits/';
  static String produitDetail(int id) => '/produits/$id/';
  static String produitPrediction(int id) => '/produits/$id/prediction/';
  static String produitForecast(int id) => '/produits/$id/forecast/';
  static String produitTrend(int id) => '/produits/$id/trend/';
  static const String produitsExport = '/exports/products/';

  // Caisse POS & Ventes
  static const String caisseCheckout = '/caisse/checkout/';
  static const String ventes = '/ventes/';
  static String venteDetail(int id) => '/ventes/$id/';

  // Stock, Mouvements & Alertes
  static const String stockAjuster = '/stock/ajuster/';
  static const String mouvements = '/mouvements/';
  static const String alertes = '/alertes/';
  static String alerteResoudre(int id) => '/alertes/$id/resoudre/';

  // Approvisionnements, Clients & Fournisseurs
  static const String approvisionnements = '/approvisionnements/';
  static const String categories = '/categories/';
  static const String clients = '/clients/';
  static String clientDetail(int id) => '/clients/$id/';
  static const String fournisseurs = '/fournisseurs/';
  static String fournisseurDetail(int id) => '/fournisseurs/$id/';

  // Statistiques, Graphiques & IA
  static const String statsSummary = '/stats/summary/';
  static const String statsTrend = '/stats/trend/';
  static String statsCategory(int id) => '/stats/category/$id/';
  static const String chartsSales = '/charts/sales/';
  static String chartsSalesProduct(int id) => '/charts/sales/product/$id/';
  static const String chartsConsumption = '/charts/consumption/';
  static const String chartsStock = '/charts/stock/';
  static const String previsions = '/previsions/';
  static const String previsionsDecision = '/previsions/decision/';

  // Notifications
  static const String notifications = '/notifications/';
  static String notificationMarquerLue(int id) => '/notifications/$id/marquer_lue/';
  static const String notificationsMarquerToutLu = '/notifications/marquer_tout_lu/';
}
