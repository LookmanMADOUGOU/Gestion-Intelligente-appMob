import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/supplier_model.dart';

class SupplierRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<SupplierModel>> getSuppliers({String? search, int page = 1}) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }

      final response = await _dio.get(ApiEndpoints.fournisseurs, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          list = data['results'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => SupplierModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: "Erreur lors du chargement des fournisseurs");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<SupplierModel> createSupplier(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(ApiEndpoints.fournisseurs, data: payload);
      if (response.statusCode == 201 && response.data != null) {
        return SupplierModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de créer la fiche fournisseur");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
