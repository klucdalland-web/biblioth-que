import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/local/stats_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/stats_remote_data_source.dart';
import 'package:front_mobile/data/models/stats_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';
import 'package:front_mobile/domain/repositories/stats_repository.dart';

/// Orchestration remote + cache local pour le dashboard.
class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._remote, this._local);

  final StatsRemoteDataSource _remote;
  final StatsLocalDataSource _local;

  @override
  Future<RepositoryResult<StatsModel>> getStats() async {
    try {
      final data = await _remote.getStats();
      await _local.save(data);
      return RepositoryResult(data);
    } on ApiException catch (e) {
      if (e.isNetwork) {
        final cached = _local.read();
        if (cached != null) {
          return RepositoryResult(cached, fromCache: true);
        }
      }
      rethrow;
    }
  }
}
