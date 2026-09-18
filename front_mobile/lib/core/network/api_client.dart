import 'dart:async';

import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/core/storage/token_storage.dart';

/// Client HTTP commun (device-key + JWT + refresh auto).
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final TokenStorage _storage;
  late final Dio _dio;
  Completer<void>? _refreshCompleter;

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicPath(options.path)) {
      final token = await _storage.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (status == 401 && !_isPublicPath(path)) {
      try {
        await _refreshToken();
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        await _storage.clearAll();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _isPublicPath(String path) {
    return path.contains('/authentification/login') ||
        path.contains('/authentification/register') ||
        path.contains('/authentification/refresh') ||
        path.contains('/authentification/logout');
  }

  Future<void> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();
    try {
      final refresh = await _storage.refreshToken;
      if (refresh == null || refresh.isEmpty) {
        throw ApiException('Session expirée');
      }

      final res = await Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            ApiConstants.deviceKeyHeader: ApiConstants.deviceKey,
          },
        ),
      ).post(ApiConstants.refresh, data: {'refreshToken': refresh});

      final data = res.data is Map ? res.data['data'] : null;
      final access = data is Map ? data['accessToken'] as String? : null;
      if (access == null) {
        throw ApiException('Refresh token invalide');
      }

      await _storage.saveTokens(accessToken: access);
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.accessToken;
    final opts = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }

  /// Extrait `data` du envelope `{ status, message, data }`.
  dynamic unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  Never throwFromDio(DioException e) {
    final body = e.response?.data;
    String message = 'Erreur réseau';
    if (body is Map && body['message'] is String) {
      message = body['message'] as String;
    } else if (e.message != null) {
      message = e.message!;
    }
    throw ApiException(message, statusCode: e.response?.statusCode);
  }
}
