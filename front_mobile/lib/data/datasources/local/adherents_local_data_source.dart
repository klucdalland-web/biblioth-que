import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/data/models/adherent_model.dart';

/// Cache local adhérents (GetStorage).
class AdherentsLocalDataSource {
  AdherentsLocalDataSource(this._cache);

  final CacheStorage _cache;

  static const maxAge = Duration(hours: 24);

  String _key(String? search) {
    final s = (search ?? '').trim().toLowerCase();
    return 'adherents_s$s';
  }

  Future<void> saveList(List<AdherentModel> items, {String? search}) {
    return _cache.writeJson(
      _key(search),
      items.map((e) => e.toJson()).toList(),
    );
  }

  List<AdherentModel>? readList({String? search}) {
    final raw = _cache.readJson(_key(search), maxAge: maxAge);
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((e) => AdherentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
