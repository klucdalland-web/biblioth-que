import 'package:dio/dio.dart';

/// Catégorie d'erreur réseau pour messages utilisateur ciblés.
enum ApiErrorType {
  timeout,
  noConnection,
  unauthorized,
  server,
  unknown,
}

/// Exception métier exposée à la présentation (jamais Dio brut).
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiErrorType.unknown,
  });

  final String message;
  final int? statusCode;
  final ApiErrorType type;

  bool get isNetwork =>
      type == ApiErrorType.timeout || type == ApiErrorType.noConnection;

  /// Convertit une [DioException] en message FR compréhensible.
  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    String? apiMessage;
    if (body is Map && body['message'] is String) {
      apiMessage = body['message'] as String;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          'Délai d’attente dépassé. Vérifiez votre connexion.',
          statusCode: status,
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Pas de connexion réseau. Affichage des données en cache si disponibles.',
          statusCode: status,
          type: ApiErrorType.noConnection,
        );
      case DioExceptionType.badResponse:
        if (status == 401 || status == 403) {
          return ApiException(
            apiMessage ?? 'Session expirée ou accès refusé.',
            statusCode: status,
            type: ApiErrorType.unauthorized,
          );
        }
        if (status != null && status >= 500) {
          return ApiException(
            apiMessage ?? 'Le serveur est temporairement indisponible.',
            statusCode: status,
            type: ApiErrorType.server,
          );
        }
        return ApiException(
          apiMessage ?? 'Erreur serveur (${status ?? '?'})',
          statusCode: status,
          type: ApiErrorType.server,
        );
      case DioExceptionType.cancel:
        return ApiException(
          'Requête annulée.',
          statusCode: status,
          type: ApiErrorType.unknown,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          'Certificat sécurisé invalide.',
          statusCode: status,
          type: ApiErrorType.server,
        );
      case DioExceptionType.unknown:
        final msg = e.message?.toLowerCase() ?? '';
        if (msg.contains('socket') ||
            msg.contains('network') ||
            msg.contains('connection')) {
          return ApiException(
            'Pas de connexion réseau. Affichage des données en cache si disponibles.',
            statusCode: status,
            type: ApiErrorType.noConnection,
          );
        }
        return ApiException(
          apiMessage ?? e.message ?? 'Erreur réseau inattendue.',
          statusCode: status,
          type: ApiErrorType.unknown,
        );
    }
  }

  @override
  String toString() => message;
}
