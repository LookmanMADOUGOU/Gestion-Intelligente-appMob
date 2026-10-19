import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/cart_item_model.dart';

class CashRegisterRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<ReceiptModel> checkout({
    required List<CartItemModel> items,
    int? clientId,
    String modePaiement = 'ESPECES',
    double remiseGlobale = 0.0,
    String notes = '',
  }) async {
    try {
      final payload = {
        'items': items.map((i) => i.toApiPayload()).toList(),
        'client_id': clientId,
        'mode_paiement': modePaiement,
        'remise_globale': remiseGlobale,
        'notes': notes,
      };

      final response = await _dio.post(ApiEndpoints.caisseCheckout, data: payload);
      if (response.statusCode == 201 && response.data != null) {
        return ReceiptModel.fromJson(response.data as Map<String, dynamic>, items);
      }
      throw ApiException(message: "Échec de l'encaissement de la vente");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
