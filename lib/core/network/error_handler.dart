import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() => message;
}

class ErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
            message: "Délai de connexion dépassé. Vérifiez votre connexion au serveur Django.",
            statusCode: 408,
          );

        case DioExceptionType.connectionError:
          return ApiException(
            message: "Impossible de joindre le serveur. Assurez-vous que le backend Django est démarré et que l'URL est correcte.",
            statusCode: 503,
          );

        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final data = error.response?.data;

          String message = "Une erreur est survenue lors de l'échange avec le serveur.";
          if (data is Map<String, dynamic>) {
            if (data.containsKey('detail')) {
              message = data['detail'].toString();
            } else if (data.containsKey('error')) {
              message = data['error'].toString();
            } else if (data.containsKey('message')) {
              message = data['message'].toString();
            } else {
              // Concaténer les erreurs de validation des champs DRF
              final fieldErrors = <String>[];
              data.forEach((k, v) {
                if (v is List) {
                  fieldErrors.add('$k : ${v.join(", ")}');
                } else {
                  fieldErrors.add('$k : $v');
                }
              });
              if (fieldErrors.isNotEmpty) {
                message = fieldErrors.join("\n");
              }
            }
          }

          if (status == 401) {
            return ApiException(
              message: message.isNotEmpty && message != "Une erreur est survenue lors de l'échange avec le serveur."
                  ? message
                  : "Session expirée ou identifiants invalides. Veuillez vous reconnecter.",
              statusCode: 401,
              details: data,
            );
          } else if (status == 403) {
            return ApiException(
              message: message.isNotEmpty ? message : "Accès non autorisé pour votre profil d'utilisateur.",
              statusCode: 403,
              details: data,
            );
          } else if (status == 404) {
            return ApiException(
              message: message.isNotEmpty ? message : "La ressource demandée est introuvable sur le serveur.",
              statusCode: 404,
              details: data,
            );
          } else if (status == 422 || status == 400) {
            return ApiException(
              message: message,
              statusCode: status,
              details: data,
            );
          } else if (status != null && status >= 500) {
            return ApiException(
              message: "Erreur interne du serveur backend ($status). Contactez l'administrateur.",
              statusCode: status,
              details: data,
            );
          }

          return ApiException(message: message, statusCode: status, details: data);

        case DioExceptionType.cancel:
          return ApiException(message: "La requête a été annulée.", statusCode: 499);

        default:
          return ApiException(message: "Problème réseau. Vérifiez votre connectivité Wi-Fi ou mobile.");
      }
    }

    return ApiException(message: error.toString());
  }
}
