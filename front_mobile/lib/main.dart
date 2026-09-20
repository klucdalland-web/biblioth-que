import 'package:flutter/material.dart';
import 'package:front_mobile/app/app.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:front_mobile/data/datasources/remote/auth_remote_data_source.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:front_mobile/domain/repositories/auth_repository.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final storage = TokenStorage();
  Get.put<TokenStorage>(storage, permanent: true);
  Get.put<CacheStorage>(CacheStorage(), permanent: true);
  Get.put<ApiClient>(ApiClient(storage), permanent: true);
  Get.put<AuthRemoteDataSource>(
    AuthRemoteDataSource(Get.find()),
    permanent: true,
  );
  Get.put<AuthRepository>(
    AuthRepositoryImpl(Get.find()),
    permanent: true,
  );
  Get.put<AuthController>(
    AuthController(Get.find(), Get.find()),
    permanent: true,
  );

  runApp(const BiblioApp());
}
