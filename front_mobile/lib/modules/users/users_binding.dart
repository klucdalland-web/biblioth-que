import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/repositories/users_repository.dart';
import 'package:front_mobile/modules/users/users_controller.dart';
import 'package:get/get.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsersRepository>()) {
      Get.lazyPut(() => UsersRepository(Get.find<ApiClient>()));
    }
    Get.lazyPut(() => UsersController(Get.find()));
  }
}
