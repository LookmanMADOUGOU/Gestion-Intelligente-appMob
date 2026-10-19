import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../../../core/storage/local_cache_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;
  static const String _cacheKeyUser = 'current_user_profile';

  Future<UserModel> login({required String username, required String password}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.token,
        data: {'username': username.trim(), 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final accessToken = response.data['access'] as String;
        final refreshToken = response.data['refresh'] as String;

        await SecureStorageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Récupérer le profil et les permissions
        return await getCurrentUser();
      } else {
        throw ApiException(message: "Échec de l'authentification (code ${response.statusCode})");
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await LocalCacheService.save(_cacheKeyUser, user.toJson());
        return user;
      }
      throw ApiException(message: "Impossible de récupérer les informations de profil.");
    } catch (e) {
      // Fallback cache local en cas de coupure réseau
      final cached = LocalCacheService.get(_cacheKeyUser);
      if (cached != null) {
        return UserModel.fromJson(cached as Map<String, dynamic>);
      }
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return await SecureStorageService.hasTokens();
  }
}
