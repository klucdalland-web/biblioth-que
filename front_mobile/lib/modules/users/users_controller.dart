import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/data/repositories/users_repository.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  UsersController(this._repo);

  final UsersRepository _repo;

  final items = <UserModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  int? get currentUserId => Get.find<AuthController>().user.value?.id;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      items.assignAll(await _repo.list());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create({
    required String nom,
    required String mail,
    required String password,
    required String role,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      await _repo.create(
        nom: nom,
        mail: mail,
        password: password,
        role: role,
      );
      await load();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateUser({
    required int id,
    required String nom,
    required String mail,
    required String role,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      await _repo.update(id: id, nom: nom, mail: mail, role: role);
      await load();
      final auth = Get.find<AuthController>();
      if (auth.user.value?.id == id) {
        await auth.refreshProfile();
      }
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> remove(int id) async {
    try {
      await _repo.remove(id);
      await load();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
