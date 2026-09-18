import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(Get.find<AuthRepository>(), Get.find<TokenStorage>()),
        permanent: true,
      );
    }
  }
}
