import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/core/middleware/admin_middleware.dart';
import 'package:front_mobile/core/middleware/auth_middleware.dart';
import 'package:front_mobile/modules/login/login_binding.dart';
import 'package:front_mobile/modules/login/login_view.dart';
import 'package:front_mobile/modules/profile/profile_view.dart';
import 'package:front_mobile/modules/shell/shell_binding.dart';
import 'package:front_mobile/modules/shell/shell_view.dart';
import 'package:front_mobile/modules/splash/splash_binding.dart';
import 'package:front_mobile/modules/splash/splash_view.dart';
import 'package:front_mobile/modules/users/users_binding.dart';
import 'package:front_mobile/modules/users/users_view.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersView(),
      binding: UsersBinding(),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
  ];
}
