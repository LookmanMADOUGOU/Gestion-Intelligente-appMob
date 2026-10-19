import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/storage/local_cache_service.dart';
import '../domain/dashboard_kpi_model.dart';

class DashboardRepository {
  final Dio _dio = ApiClient.instance.dio;
  static const String _cacheKeyDashboard = 'dashboard_kpi_data';

  Future<DashboardKpiModel> fetchDashboardData({int trendDays = 14}) async {
    try {
      final summaryRes = await _dio.get(ApiEndpoints.statsSummary);
      final trendRes = await _dio.get(
        ApiEndpoints.chartsSales,
        queryParameters: {'days': trendDays},
      );

      if (summaryRes.statusCode == 200) {
        final summaryData = summaryRes.data as Map<String, dynamic>;
        final salesTrendData = trendRes.data as List<dynamic>?;

        final kpi = DashboardKpiModel.fromJson(summaryData, salesTrendData);
        await LocalCacheService.save(_cacheKeyDashboard, kpi.toJson());
        return kpi;
      }

      throw ApiException(message: "Erreur lors de la récupération des données du dashboard");
    } catch (e) {
      // Fallback cache local hors ligne
      final cached = LocalCacheService.get(_cacheKeyDashboard);
      if (cached != null) {
        final cachedMap = cached as Map<String, dynamic>;
        return DashboardKpiModel(
          totalProducts: cachedMap['total_products'] as int? ?? 0,
          totalStock: cachedMap['total_stock'] as int? ?? 0,
          productsInRupture: cachedMap['products_in_rupture'] as int? ?? 0,
          activeAlerts: cachedMap['active_alerts'] as int? ?? 0,
          topConsumed: (cachedMap['top_consumed'] as List<dynamic>?)
                  ?.map((e) => TopConsumedProduct.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
          salesTrend: (cachedMap['sales_trend'] as List<dynamic>?)
                  ?.map((e) => DailySalesPoint.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        );
      }
      throw ErrorHandler.handle(e);
    }
  }
}
