class TopConsumedProduct {
  final int produitId;
  final String produitNom;
  final int quantite;

  TopConsumedProduct({
    required this.produitId,
    required this.produitNom,
    required this.quantite,
  });

  factory TopConsumedProduct.fromJson(Map<String, dynamic> json) {
    return TopConsumedProduct(
      produitId: json['produit_id'] as int? ?? 0,
      produitNom: json['produit_nom'] as String? ?? 'Produit #${json['produit_id']}',
      quantite: json['quantite'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'produit_id': produitId,
    'produit_nom': produitNom,
    'quantite': quantite,
  };
}

class DailySalesPoint {
  final String date;
  final int quantite;

  DailySalesPoint({required this.date, required this.quantite});

  factory DailySalesPoint.fromJson(Map<String, dynamic> json) {
    return DailySalesPoint(
      date: json['date'] as String? ?? '',
      quantite: json['quantite'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'quantite': quantite,
  };
}

class DashboardKpiModel {
  final int totalProducts;
  final int totalStock;
  final int productsInRupture;
  final int activeAlerts;
  final List<TopConsumedProduct> topConsumed;
  final List<DailySalesPoint> salesTrend;

  DashboardKpiModel({
    required this.totalProducts,
    required this.totalStock,
    required this.productsInRupture,
    required this.activeAlerts,
    required this.topConsumed,
    required this.salesTrend,
  });

  factory DashboardKpiModel.fromJson(Map<String, dynamic> summary, List<dynamic>? trendSales) {
    final topList = (summary['top_consumed'] as List<dynamic>?)
            ?.map((e) => TopConsumedProduct.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final salesList = (trendSales ?? [])
        .map((e) => DailySalesPoint.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardKpiModel(
      totalProducts: summary['total_products'] as int? ?? 0,
      totalStock: summary['total_stock'] as int? ?? 0,
      productsInRupture: summary['products_in_rupture'] as int? ?? 0,
      activeAlerts: summary['active_alerts'] as int? ?? 0,
      topConsumed: topList,
      salesTrend: salesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_products': totalProducts,
    'total_stock': totalStock,
    'products_in_rupture': productsInRupture,
    'active_alerts': activeAlerts,
    'top_consumed': topConsumed.map((e) => e.toJson()).toList(),
    'sales_trend': salesTrend.map((e) => e.toJson()).toList(),
  };
}
