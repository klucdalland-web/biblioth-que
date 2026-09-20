import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/datasources/remote/users_remote_data_source.dart';
import 'package:front_mobile/data/repositories/users_repository.dart';
import 'package:front_mobile/domain/repositories/users_repository.dart';
import 'package:front_mobile/modules/users/users_controller.dart';
import 'package:get/get.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UsersRemoteDataSource>()) {
      Get.lazyPut(() => UsersRemoteDataSource(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<UsersRepository>()) {
      Get.lazyPut<UsersRepository>(
        () => UsersRepositoryImpl(Get.find()),
      );
    }
    Get.lazyPut(() => UsersController(Get.find()));
  }
}
