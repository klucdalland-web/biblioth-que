import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/user_model.dart';

class UsersRepository {
  UsersRepository(this._api);

  final ApiClient _api;

  Future<List<UserModel>> list() async {
    try {
      final res = await _api.dio.get(ApiConstants.users);
      final data = _api.unwrap(res);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<UserModel> create({
    required String nom,
    required String mail,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.users,
        data: {
          'nom': nom,
          'mail': mail,
          'password': password,
          'role': role,
        },
      );
      final data = _api.unwrap(res);
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<UserModel> update({
    required int id,
    required String nom,
    required String mail,
    required String role,
  }) async {
    try {
      final res = await _api.dio.put(
        '${ApiConstants.users}/$id',
        data: {'nom': nom, 'mail': mail, 'role': role},
      );
      final data = _api.unwrap(res);
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _api.dio.delete('${ApiConstants.users}/$id');
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }
}
