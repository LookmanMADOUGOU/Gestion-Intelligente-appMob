import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final void Function()? onSessionExpired;

  AuthInterceptor({required this.dio, this.onSessionExpired});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ne pas ajouter le token pour l'appel de login ou refresh
    if (options.path.contains(ApiEndpoints.token)) {
      return handler.next(options);
    }

    final token = await SecureStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiEndpoints.token)) {
      // Tenter de renouveler le token d'accès
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Créer un Dio isolé pour éviter les boucles d'interception
          final refreshDio = Dio(BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            headers: {'Content-Type': 'application/json'},
          ));

          final refreshResponse = await refreshDio.post(
            ApiEndpoints.tokenRefresh,
            data: {'refresh': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newAccess = refreshResponse.data['access'] as String;
            await SecureStorageService.saveAccessToken(newAccess);

            // Rejouer la requête d'origine avec le nouveau token
            final originalOptions = err.requestOptions;
            originalOptions.headers['Authorization'] = 'Bearer $newAccess';

            final retryResponse = await dio.fetch(originalOptions);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Échec du renouvellement -> session définitivement expirée
          await SecureStorageService.clearTokens();
          onSessionExpired?.call();
        }
      } else {
        await SecureStorageService.clearTokens();
        onSessionExpired?.call();
      }
    }

    return handler.next(err);
  }
}
