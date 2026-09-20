import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/local/adherents_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/adherents_remote_data_source.dart';
import 'package:front_mobile/data/models/adherent_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';
import 'package:front_mobile/domain/repositories/adherents_repository.dart';

/// Orchestration remote + cache local pour les adhérents.
class AdherentsRepositoryImpl implements AdherentsRepository {
  AdherentsRepositoryImpl(this._remote, this._local);

  final AdherentsRemoteDataSource _remote;
  final AdherentsLocalDataSource _local;

  @override
  Future<RepositoryResult<List<AdherentModel>>> list({String? search}) async {
    try {
      final data = await _remote.list(search: search);
      await _local.saveList(data, search: search);
      return RepositoryResult(data);
    } on ApiException catch (e) {
      if (e.isNetwork) {
        final cached = _local.readList(search: search);
        if (cached != null) {
          return RepositoryResult(cached, fromCache: true);
        }
      }
      rethrow;
    }
  }

  @override
  Future<AdherentModel> create({
    required String nom,
    required String contact,
  }) =>
      _remote.create(nom: nom, contact: contact);

  @override
  Future<void> remove(int id) => _remote.remove(id);
}
