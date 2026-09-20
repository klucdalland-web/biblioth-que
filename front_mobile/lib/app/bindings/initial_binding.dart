import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:front_mobile/data/datasources/remote/auth_remote_data_source.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:front_mobile/domain/repositories/auth_repository.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TokenStorage>()) {
      Get.put<TokenStorage>(TokenStorage(), permanent: true);
    }
    if (!Get.isRegistered<CacheStorage>()) {
      Get.put<CacheStorage>(CacheStorage(), permanent: true);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(Get.find()), permanent: true);
    }
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.put<AuthRemoteDataSource>(
        AuthRemoteDataSource(Get.find()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepositoryImpl(Get.find()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(Get.find(), Get.find()),
        permanent: true,
      );
    }
  }
}
