import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/auteur_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';

class LivresRepository {
  LivresRepository(this._api);

  final ApiClient _api;

  Future<PaginatedLivres> list({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final res = await _api.dio.get(
        ApiConstants.livres,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      return PaginatedLivres.fromJson(_api.unwrap(res));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<List<AuteurModel>> listAuteurs() async {
    try {
      final res = await _api.dio.get(ApiConstants.auteurs);
      final data = _api.unwrap(res);
      if (data is! List) return [];
      return data
          .whereType<Map>()
          .map((e) => AuteurModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<LivreModel> create({
    required String titre,
    required int idAuteur,
    int? anneePublication,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.livres,
        data: {
          'titre': titre,
          'id_auteur': idAuteur,
          if (anneePublication != null) 'annee_publication': anneePublication,
        },
      );
      final data = _api.unwrap(res);
      return LivreModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await _api.dio.delete('${ApiConstants.livres}/$id');
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }
}
