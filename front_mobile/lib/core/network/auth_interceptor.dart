import 'dart:async';

import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/core/storage/token_storage.dart';

/// Intercepteur JWT explicite : attache le Bearer et rafraîchit le token sur 401.
///
/// Le refresh est single-flight (une seule requête refresh à la fois) pour
/// éviter les courses critiques quand plusieurs appels échouent ensemble.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final TokenStorage _storage;
  Completer<void>? _refreshCompleter;

  @override
  Future<void> onRequest(
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

  @override
  Future<void> onError(
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
        throw ApiException(
          'Session expirée',
          type: ApiErrorType.unauthorized,
        );
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
        throw ApiException(
          'Refresh token invalide',
          type: ApiErrorType.unauthorized,
        );
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
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          ApiConstants.deviceKeyHeader: ApiConstants.deviceKey,
        },
      ),
    );
    final opts = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }
}
