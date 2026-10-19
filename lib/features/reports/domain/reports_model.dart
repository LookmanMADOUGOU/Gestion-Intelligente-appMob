class SalesTrendPoint {
  final String date;
  final int quantite;

  SalesTrendPoint({required this.date, required this.quantite});

  factory SalesTrendPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendPoint(
      date: json['date'] as String? ?? '',
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
    );
  }
}

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
      produitNom: json['produit_nom'] as String? ?? '',
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReportsSummaryModel {
  final int totalProducts;
  final int totalStock;
  final int productsInRupture;
  final int activeAlerts;
  final List<TopConsumedProduct> topConsumed;

  ReportsSummaryModel({
    required this.totalProducts,
    required this.totalStock,
    required this.productsInRupture,
    required this.activeAlerts,
    required this.topConsumed,
  });

  factory ReportsSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawTop = json['top_consumed'] as List<dynamic>? ?? [];
    return ReportsSummaryModel(
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalStock: (json['total_stock'] as num?)?.toInt() ?? 0,
      productsInRupture: (json['products_in_rupture'] as num?)?.toInt() ?? 0,
      activeAlerts: (json['active_alerts'] as num?)?.toInt() ?? 0,
      topConsumed: rawTop.map((e) => TopConsumedProduct.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SalesTrendReportModel {
  final int periodDays;
  final List<SalesTrendPoint> sales;

  SalesTrendReportModel({required this.periodDays, required this.sales});

  factory SalesTrendReportModel.fromJson(Map<String, dynamic> json) {
    final rawSales = json['sales'] as List<dynamic>? ?? [];
    return SalesTrendReportModel(
      periodDays: (json['period_days'] as num?)?.toInt() ?? 30,
      sales: rawSales.map((e) => SalesTrendPoint.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
