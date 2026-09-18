import 'package:flutter/widgets.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';

/// Accès réservé aux admins (page users).
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.shell);
    }
    final auth = Get.find<AuthController>();
    if (auth.user.value == null || !auth.user.value!.isAdmin) {
      return const RouteSettings(name: AppRoutes.shell);
    }
    return null;
  }
}
