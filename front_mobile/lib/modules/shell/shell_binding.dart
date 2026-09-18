import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/repositories/adherents_repository.dart';
import 'package:front_mobile/data/repositories/emprunts_repository.dart';
import 'package:front_mobile/data/repositories/livres_repository.dart';
import 'package:front_mobile/data/repositories/stats_repository.dart';
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

    if (!Get.isRegistered<StatsRepository>()) {
      Get.lazyPut(() => StatsRepository(api));
    }
    if (!Get.isRegistered<LivresRepository>()) {
      Get.lazyPut(() => LivresRepository(api));
    }
    if (!Get.isRegistered<AdherentsRepository>()) {
      Get.lazyPut(() => AdherentsRepository(api));
    }
    if (!Get.isRegistered<EmpruntsRepository>()) {
      Get.lazyPut(() => EmpruntsRepository(api));
    }

    Get.lazyPut(() => ShellController());
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

    // Auth déjà permanent via main / InitialBinding
    Get.find<AuthController>();
  }
}
