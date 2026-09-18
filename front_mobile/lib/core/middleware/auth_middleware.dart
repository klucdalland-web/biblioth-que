import 'package:flutter/widgets.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:get/get.dart';

/// Redirige vers login si pas de session (flag sync GetStorage).
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<TokenStorage>();
    if (!storage.hasSession) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
