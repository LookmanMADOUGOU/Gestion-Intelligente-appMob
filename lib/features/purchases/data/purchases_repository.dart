import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/purchase_model.dart';

class PurchasesRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<PurchaseModel>> getPurchases({int page = 1, String? search}) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      final response = await _dio.get(ApiEndpoints.approvisionnements, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          list = data['results'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: "Erreur lors de la récupération des approvisionnements");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<PurchaseModel> createPurchase(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(ApiEndpoints.approvisionnements, data: payload);
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return PurchaseModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible d'enregistrer l'approvisionnement");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
