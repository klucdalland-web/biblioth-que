import 'package:flutter/material.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/modules/adherents/adherents_view.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:front_mobile/modules/dashboard/dashboard_view.dart';
import 'package:front_mobile/modules/emprunts/emprunts_view.dart';
import 'package:front_mobile/modules/livres/livres_view.dart';
import 'package:front_mobile/modules/shell/shell_controller.dart';
import 'package:get/get.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final pages = const [
      DashboardView(),
      LivresView(),
      AdherentsView(),
      EmpruntsView(),
    ];

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(_titleFor(controller.currentIndex.value)),
          actions: [
            if (auth.isAdmin)
              IconButton(
                tooltip: 'Utilisateurs',
                onPressed: () => Get.toNamed(AppRoutes.users),
                icon: const Icon(Icons.group_outlined),
              ),
            IconButton(
              tooltip: 'Profil',
              onPressed: () => Get.toNamed(AppRoutes.profile),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Livres',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Adhérents',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_outlined),
              selectedIcon: Icon(Icons.swap_horiz),
              label: 'Emprunts',
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(int index) {
    switch (index) {
      case 1:
        return 'Livres';
      case 2:
        return 'Adhérents';
      case 3:
        return 'Emprunts';
      default:
        return 'Tableau de bord';
    }
  }
}
