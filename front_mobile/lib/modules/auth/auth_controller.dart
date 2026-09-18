import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:get/get.dart';

/// Session globale (login / me / logout).
class AuthController extends GetxController {
  AuthController(this._repo, this._storage);

  final AuthRepository _repo;
  final TokenStorage _storage;

  final user = Rxn<UserModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  bool get isAdmin => user.value?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    final cached = _storage.userJson;
    if (cached != null) {
      user.value = UserModel.fromJson(cached);
    }
  }

  Future<bool> restoreSession() async {
    if (!_storage.hasSession) return false;
    try {
      final me = await _repo.me();
      user.value = me;
      _storage.saveUserJson(me.toJson());
      return true;
    } catch (_) {
      await _storage.clearAll();
      user.value = null;
      return false;
    }
  }

  Future<void> login({
    required String mail,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final tokens = await _repo.login(mail: mail, password: password);
      await _storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      if (tokens.user != null) {
        user.value = tokens.user;
        _storage.saveUserJson(tokens.user!.toJson());
      } else {
        await restoreSession();
      }
      Get.offAllNamed(AppRoutes.shell);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.refreshToken;
    if (refresh != null) {
      await _repo.logout(refresh);
    }
    await _storage.clearAll();
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> refreshProfile() async {
    final me = await _repo.me();
    user.value = me;
    _storage.saveUserJson(me.toJson());
  }
}
