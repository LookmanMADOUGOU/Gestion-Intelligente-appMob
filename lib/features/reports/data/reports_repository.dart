import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/prediction_model.dart';
import '../domain/reports_model.dart';

class ReportsRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<ReportsSummaryModel> getSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.statsSummary);
      if (response.statusCode == 200 && response.data != null) {
        return ReportsSummaryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de charger les statistiques globales");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<SalesTrendReportModel> getSalesTrend({int days = 30}) async {
    try {
      final response = await _dio.get(ApiEndpoints.statsTrend, queryParameters: {'days': days});
      if (response.statusCode == 200 && response.data != null) {
        return SalesTrendReportModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de charger les tendances de vente");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<DecisionSupportSummaryModel> getDecisionSupport({String? category, String? query}) async {
    try {
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty) params['categorie'] = category;
      if (query != null && query.isNotEmpty) params['q'] = query;

      final response = await _dio.get(ApiEndpoints.previsionsDecision, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        return DecisionSupportSummaryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de charger les prévisions IA d'aide à la décision");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
