import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/local/livres_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/livres_remote_data_source.dart';
import 'package:front_mobile/data/models/auteur_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';
import 'package:front_mobile/domain/repositories/livres_repository.dart';

/// Orchestration remote + cache local pour les livres.
class LivresRepositoryImpl implements LivresRepository {
  LivresRepositoryImpl(this._remote, this._local);

  final LivresRemoteDataSource _remote;
  final LivresLocalDataSource _local;

  @override
  Future<RepositoryResult<PaginatedLivres>> list({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final data = await _remote.list(
        search: search,
        page: page,
        limit: limit,
      );
      await _local.saveList(
        data,
        search: search,
        page: page,
        limit: limit,
      );
      return RepositoryResult(data);
    } on ApiException catch (e) {
      if (e.isNetwork) {
        final cached = _local.readList(
          search: search,
          page: page,
          limit: limit,
        );
        if (cached != null) {
          return RepositoryResult(cached, fromCache: true);
        }
      }
      rethrow;
    }
  }

  @override
  Future<RepositoryResult<List<AuteurModel>>> listAuteurs() async {
    try {
      final data = await _remote.listAuteurs();
      await _local.saveAuteurs(data);
      return RepositoryResult(data);
    } on ApiException catch (e) {
      if (e.isNetwork) {
        final cached = _local.readAuteurs();
        if (cached != null) {
          return RepositoryResult(cached, fromCache: true);
        }
      }
      rethrow;
    }
  }

  @override
  Future<LivreModel> create({
    required String titre,
    required int idAuteur,
    int? anneePublication,
  }) =>
      _remote.create(
        titre: titre,
        idAuteur: idAuteur,
        anneePublication: anneePublication,
      );

  @override
  Future<void> remove(int id) => _remote.remove(id);
}
