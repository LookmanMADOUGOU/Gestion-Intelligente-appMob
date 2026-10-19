import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/error_handler.dart';
import '../domain/alert_model.dart';

class AlertsRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<AlerteModel>> getAlerts({bool? resolved}) async {
    try {
      final params = <String, dynamic>{};
      if (resolved != null) params['est_resolue'] = resolved;

      final response = await _dio.get(ApiEndpoints.alertes, queryParameters: params);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          list = data['results'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => AlerteModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: "Impossible de récupérer les alertes de stock");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> resolveAlert(int alertId) async {
    try {
      final response = await _dio.post(ApiEndpoints.alerteResoudre(alertId));
      if (response.statusCode != 200) {
        throw ApiException(message: "Erreur lors de la résolution de l'alerte");
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.notifications);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map<String, dynamic>) {
          list = data['results'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ApiException(message: "Impossible de récupérer les notifications");
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _dio.post(ApiEndpoints.notificationMarquerLue(notificationId));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.post(ApiEndpoints.notificationsMarquerToutLu);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
