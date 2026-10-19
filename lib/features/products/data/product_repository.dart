import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/storage/local_cache_service.dart';
import '../domain/product_model.dart';

class ProductListResult {
  final List<ProductModel> products;
  final int count;
  final bool hasNext;

  ProductListResult({
    required this.products,
    required this.count,
    required this.hasNext,
  });
}

class ProductRepository {
  final Dio _dio = ApiClient.instance.dio;
  static const String _cacheKeyProducts = 'products_catalog';

  Future<ProductListResult> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isRupture,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (categoryId != null) {
        queryParams['categorie'] = categoryId;
      }
      if (isRupture != null) {
        queryParams['rupture'] = isRupture;
      }

      final response = await _dio.get(
        ApiEndpoints.produits,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> results = [];
        int count = 0;
        bool hasNext = false;

        if (data is Map<String, dynamic>) {
          results = data['results'] as List<dynamic>? ?? [];
          count = data['count'] as int? ?? results.length;
          hasNext = data['next'] != null;
        } else if (data is List) {
          results = data;
          count = results.length;
        }

        final products = results
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Mettre en cache la première page par défaut pour l'accès hors ligne
        if (page == 1 && (search == null || search.isEmpty) && categoryId == null && isRupture == null) {
          await LocalCacheService.save(_cacheKeyProducts, results);
        }

        return ProductListResult(products: products, count: count, hasNext: hasNext);
      }

      throw ApiException(message: "Erreur lors du chargement des produits");
    } catch (e) {
      // Fallback cache local hors ligne pour la page 1
      if (page == 1) {
        final cached = LocalCacheService.get(_cacheKeyProducts);
        if (cached is List) {
          final list = cached
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return ProductListResult(products: list, count: list.length, hasNext: false);
        }
      }
      throw ErrorHandler.handle(e);
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.produitDetail(id));
      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Produit introuvable");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(ApiEndpoints.produits, data: payload);
      if (response.statusCode == 201 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de créer le produit");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<ProductModel> updateProduct(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.patch(ApiEndpoints.produitDetail(id), data: payload);
      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ApiException(message: "Impossible de mettre à jour le produit");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<Map<String, dynamic>> getProductPrediction(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.produitPrediction(id));
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {'prediction_ml': 'Indisponible', 'prediction_rupture': 'Indisponible'};
    }
  }

  Future<Map<String, dynamic>> getProductForecast(int id, {int days = 7}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.produitForecast(id),
        queryParameters: {'days': days},
      );
      return response.data as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }
}
