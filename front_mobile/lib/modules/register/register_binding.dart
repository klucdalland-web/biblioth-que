import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:front_mobile/modules/register/register_controller.dart';
import 'package:get/get.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<AuthController>()),
    );
  }
}
