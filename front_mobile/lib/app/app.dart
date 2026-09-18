import 'package:flutter/material.dart';
import 'package:front_mobile/app/bindings/initial_binding.dart';
import 'package:front_mobile/app/routes/app_pages.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/app/theme/app_theme.dart';
import 'package:get/get.dart';

class BiblioApp extends StatelessWidget {
  const BiblioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BiblioGestion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
