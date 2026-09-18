import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/emprunt_model.dart';

class EmpruntsRepository {
  EmpruntsRepository(this._api);

  final ApiClient _api;

  Future<List<EmpruntModel>> list() async {
    try {
      final res = await _api.dio.get(ApiConstants.emprunts);
      final data = _api.unwrap(res);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => EmpruntModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<List<EmpruntModel>> listRetard() async {
    try {
      final res = await _api.dio.get(ApiConstants.empruntsRetard);
      final data = _api.unwrap(res);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map(
            (e) => EmpruntModel.fromJson({
              ...Map<String, dynamic>.from(e),
              'statut': 'en_retard',
            }),
          )
          .toList();
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<EmpruntModel> create({
    required int idAdherent,
    required int idLivre,
    required String dateRetourPrevue,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.emprunts,
        data: {
          'id_adherent': idAdherent,
          'id_livre': idLivre,
          'date_retour_prevue': dateRetourPrevue,
        },
      );
      final data = _api.unwrap(res);
      return EmpruntModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> retour(int id) async {
    try {
      await _api.dio.put('${ApiConstants.emprunts}/$id/retour', data: {});
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }
}
