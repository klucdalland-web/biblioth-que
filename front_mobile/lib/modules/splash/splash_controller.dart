import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final auth = Get.find<AuthController>();
    final ok = await auth.restoreSession();
    if (ok) {
      Get.offAllNamed(AppRoutes.shell);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
