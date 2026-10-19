import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/stock_movement_model.dart';

class InventoryRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<StockMovementModel>> getMovements({
    int? productId,
    String? typeMouvement,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (productId != null) params['produit'] = productId;
      if (typeMouvement != null && typeMouvement.isNotEmpty) {
        params['type_mouvement'] = typeMouvement;
      }

      final response = await _dio.get(ApiEndpoints.mouvements, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          list = data['results'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => StockMovementModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: "Erreur lors du chargement des mouvements");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>> ajusterStock({
    required int produitId,
    int? nouvelleQuantite,
    int? quantite,
    String typeMouvement = 'AJUSTEMENT',
    String commentaire = '',
  }) async {
    try {
      final payload = {
        'produit_id': produitId,
        'type_mouvement': typeMouvement,
        'commentaire': commentaire,
      };
      if (nouvelleQuantite != null) {
        payload['nouvelle_quantite'] = nouvelleQuantite;
      } else if (quantite != null) {
        payload['quantite'] = quantite;
      }

      final response = await _dio.post(ApiEndpoints.stockAjuster, data: payload);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw ApiException(message: "Échec de l'ajustement du stock");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
