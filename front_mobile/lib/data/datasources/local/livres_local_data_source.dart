import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/data/models/auteur_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';

/// Cache local livres / auteurs (GetStorage).
class LivresLocalDataSource {
  LivresLocalDataSource(this._cache);

  final CacheStorage _cache;

  static const _auteursKey = 'auteurs_all';
  static const maxAge = Duration(hours: 24);

  String _listKey({String? search, required int page, required int limit}) {
    final s = (search ?? '').trim().toLowerCase();
    return 'livres_p${page}_l${limit}_s$s';
  }

  Future<void> saveList(
    PaginatedLivres data, {
    String? search,
    required int page,
    required int limit,
  }) {
    return _cache.writeJson(
      _listKey(search: search, page: page, limit: limit),
      data.toJson(),
    );
  }

  PaginatedLivres? readList({
    String? search,
    required int page,
    required int limit,
  }) {
    final raw = _cache.readJson(
      _listKey(search: search, page: page, limit: limit),
      maxAge: maxAge,
    );
    if (raw == null) return null;
    return PaginatedLivres.fromJson(raw);
  }

  Future<void> saveAuteurs(List<AuteurModel> auteurs) {
    return _cache.writeJson(
      _auteursKey,
      auteurs.map((e) => e.toJson()).toList(),
    );
  }

  List<AuteurModel>? readAuteurs() {
    final raw = _cache.readJson(_auteursKey, maxAge: maxAge);
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((e) => AuteurModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
