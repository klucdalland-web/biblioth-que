import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

/// Persistance des tokens + infos user légères.
class TokenStorage {
  TokenStorage() {
    _box = GetStorage();
  }

  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';
  static const _userJsonKey = 'user';
  static const _sessionKey = 'hasSession';

  late final GetStorage _box;
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  bool get hasSession => _box.read(_sessionKey) == true;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secure.write(key: _accessKey, value: accessToken);
    if (refreshToken != null) {
      await _secure.write(key: _refreshKey, value: refreshToken);
    }
    _box.write(_sessionKey, true);
  }

  Future<String?> get accessToken => _secure.read(key: _accessKey);

  Future<String?> get refreshToken => _secure.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await _secure.delete(key: _accessKey);
    await _secure.delete(key: _refreshKey);
    _box.write(_sessionKey, false);
  }

  void saveUserJson(Map<String, dynamic> user) {
    _box.write(_userJsonKey, user);
  }

  Map<String, dynamic>? get userJson {
    final raw = _box.read(_userJsonKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  void clearUser() => _box.remove(_userJsonKey);

  Future<void> clearAll() async {
    await clearTokens();
    clearUser();
  }
}
