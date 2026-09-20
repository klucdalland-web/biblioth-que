import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/data/models/stats_model.dart';

/// Cache local statistiques dashboard.
class StatsLocalDataSource {
  StatsLocalDataSource(this._cache);

  final CacheStorage _cache;

  static const _key = 'stats_dashboard';
  static const maxAge = Duration(hours: 12);

  Future<void> save(StatsModel stats) {
    return _cache.writeJson(_key, stats.toJson());
  }

  StatsModel? read() {
    final raw = _cache.readJson(_key, maxAge: maxAge);
    if (raw is! Map) return null;
    return StatsModel.fromJson(Map<String, dynamic>.from(raw));
  }
}
