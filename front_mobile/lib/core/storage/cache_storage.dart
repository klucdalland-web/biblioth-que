import 'package:get_storage/get_storage.dart';

/// Persistance locale JSON pour le mode hors ligne (GetStorage).
///
/// Chaque entrée est stockée avec un horodatage ; un TTL optionnel permet
/// d'invalider les données trop anciennes.
class CacheStorage {
  CacheStorage([GetStorage? box]) : _box = box ?? GetStorage();

  final GetStorage _box;

  static const _prefix = 'cache_';

  /// Écrit [data] sous [key] avec un timestamp ISO.
  Future<void> writeJson(String key, Object? data) async {
    await _box.write('$_prefix$key', {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  /// Lit le payload sous [key], ou `null` si absent / TTL dépassé.
  dynamic readJson(String key, {Duration? maxAge}) {
    final raw = _box.read('$_prefix$key');
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);
    if (maxAge != null) {
      final cachedAtRaw = map['cachedAt'] as String?;
      if (cachedAtRaw != null) {
        final cachedAt = DateTime.tryParse(cachedAtRaw);
        if (cachedAt != null &&
            DateTime.now().difference(cachedAt) > maxAge) {
          return null;
        }
      }
    }
    return map['data'];
  }

  Future<void> remove(String key) async {
    await _box.remove('$_prefix$key');
  }

  Future<void> clearAll() async {
    final keys = _box.getKeys().where((k) => k.toString().startsWith(_prefix));
    for (final key in keys) {
      await _box.remove(key);
    }
  }
}
