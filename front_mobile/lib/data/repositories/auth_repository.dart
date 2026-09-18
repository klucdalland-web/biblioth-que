import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/auth_tokens_model.dart';
import 'package:front_mobile/data/models/user_model.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthTokensModel> login({
    required String mail,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.login,
        data: {'mail': mail, 'password': password},
      );
      final data = _api.unwrap(res) as Map<String, dynamic>;
      return AuthTokensModel.fromJson(data);
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<UserModel> me() async {
    try {
      final res = await _api.dio.get(ApiConstants.me);
      final data = _api.unwrap(res) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<UserModel> updateMe({
    required String nom,
    required String mail,
  }) async {
    try {
      final res = await _api.dio.put(
        ApiConstants.me,
        data: {'nom': nom, 'mail': mail},
      );
      final data = _api.unwrap(res) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> changePassword({
    required String passwordActuel,
    required String password,
    required String confirmation,
  }) async {
    try {
      await _api.dio.put(
        ApiConstants.mePassword,
        data: {
          'password_actuel': passwordActuel,
          'password': password,
          'confirmation_mdp': confirmation,
        },
      );
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _api.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException {
      // on ignore : déconnexion locale quand même
    }
  }
}
