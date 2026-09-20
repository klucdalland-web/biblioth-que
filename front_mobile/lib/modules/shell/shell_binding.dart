import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/core/storage/cache_storage.dart';
import 'package:front_mobile/data/datasources/local/adherents_local_data_source.dart';
import 'package:front_mobile/data/datasources/local/livres_local_data_source.dart';
import 'package:front_mobile/data/datasources/local/stats_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/adherents_remote_data_source.dart';
import 'package:front_mobile/data/datasources/remote/emprunts_remote_data_source.dart';
import 'package:front_mobile/data/datasources/remote/livres_remote_data_source.dart';
import 'package:front_mobile/data/datasources/remote/stats_remote_data_source.dart';
import 'package:front_mobile/data/repositories/adherents_repository.dart';
import 'package:front_mobile/data/repositories/emprunts_repository.dart';
import 'package:front_mobile/data/repositories/livres_repository.dart';
import 'package:front_mobile/data/repositories/stats_repository.dart';
import 'package:front_mobile/domain/repositories/adherents_repository.dart';
import 'package:front_mobile/domain/repositories/emprunts_repository.dart';
import 'package:front_mobile/domain/repositories/livres_repository.dart';
import 'package:front_mobile/domain/repositories/stats_repository.dart';
import 'package:front_mobile/modules/adherents/adherents_controller.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:front_mobile/modules/dashboard/dashboard_controller.dart';
import 'package:front_mobile/modules/emprunts/emprunts_controller.dart';
import 'package:front_mobile/modules/livres/livres_controller.dart';
import 'package:front_mobile/modules/shell/shell_controller.dart';
import 'package:get/get.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.find<ApiClient>();
    final cache = Get.find<CacheStorage>();

    if (!Get.isRegistered<StatsRemoteDataSource>()) {
      Get.lazyPut(() => StatsRemoteDataSource(api));
    }
    if (!Get.isRegistered<StatsLocalDataSource>()) {
      Get.lazyPut(() => StatsLocalDataSource(cache));
    }
    if (!Get.isRegistered<StatsRepository>()) {
      Get.lazyPut<StatsRepository>(
        () => StatsRepositoryImpl(Get.find(), Get.find()),
      );
    }

    if (!Get.isRegistered<LivresRemoteDataSource>()) {
      Get.lazyPut(() => LivresRemoteDataSource(api));
    }
    if (!Get.isRegistered<LivresLocalDataSource>()) {
      Get.lazyPut(() => LivresLocalDataSource(cache));
    }
    if (!Get.isRegistered<LivresRepository>()) {
      Get.lazyPut<LivresRepository>(
        () => LivresRepositoryImpl(Get.find(), Get.find()),
      );
    }

    if (!Get.isRegistered<AdherentsRemoteDataSource>()) {
      Get.lazyPut(() => AdherentsRemoteDataSource(api));
    }
    if (!Get.isRegistered<AdherentsLocalDataSource>()) {
      Get.lazyPut(() => AdherentsLocalDataSource(cache));
    }
    if (!Get.isRegistered<AdherentsRepository>()) {
      Get.lazyPut<AdherentsRepository>(
        () => AdherentsRepositoryImpl(Get.find(), Get.find()),
      );
    }

    if (!Get.isRegistered<EmpruntsRemoteDataSource>()) {
      Get.lazyPut(() => EmpruntsRemoteDataSource(api));
    }
    if (!Get.isRegistered<EmpruntsRepository>()) {
      Get.lazyPut<EmpruntsRepository>(
        () => EmpruntsRepositoryImpl(Get.find()),
      );
    }

    Get.lazyPut(ShellController.new);
    Get.lazyPut(() => DashboardController(Get.find<StatsRepository>()));
    Get.lazyPut(() => LivresController(Get.find<LivresRepository>()));
    Get.lazyPut(() => AdherentsController(Get.find<AdherentsRepository>()));
    Get.lazyPut(
      () => EmpruntsController(
        Get.find<EmpruntsRepository>(),
        Get.find<AdherentsRepository>(),
        Get.find<LivresRepository>(),
      ),
    );

    Get.find<AuthController>();
  }
}
