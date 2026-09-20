import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/core/network/auth_interceptor.dart';
import 'package:front_mobile/core/storage/token_storage.dart';

/// Client HTTP commun (device-key + [AuthInterceptor] JWT/refresh).
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          ApiConstants.deviceKeyHeader: ApiConstants.deviceKey,
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storage));
  }

  final TokenStorage _storage;
  late final Dio _dio;

  Dio get dio => _dio;

  /// Extrait `data` du envelope `{ status, message, data }`.
  dynamic unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Convertit une [DioException] en [ApiException] typée (messages FR).
  Never throwFromDio(DioException e) {
    throw ApiException.fromDio(e);
  }
}
