import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/adherent_model.dart';

class AdherentsRepository {
  AdherentsRepository(this._api);

  final ApiClient _api;

  Future<List<AdherentModel>> list({String? search}) async {
    try {
      final res = await _api.dio.get(
        ApiConstants.adherents,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final data = _api.unwrap(res);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => AdherentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<AdherentModel> create({
    required String nom,
    required String contact,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.adherents,
        data: {'nom': nom, 'contact': contact},
      );
      final data = _api.unwrap(res);
      return AdherentModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _api.dio.delete('${ApiConstants.adherents}/$id');
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }
}
