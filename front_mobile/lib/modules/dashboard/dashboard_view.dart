import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:front_mobile/modules/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final s = controller.stats.value;
      final name = auth.user.value?.nom ?? 'Bibliothécaire';

      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, $name',
                    style: GoogleFonts.fraunces(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vue d’ensemble de la bibliothèque',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.errorMessage.value.isNotEmpty)
              ErrorBanner(
                message: controller.errorMessage.value,
                onRetry: controller.load,
              ),
            if (controller.isLoading.value && s == null)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: LoadingView(),
              )
            else if (s != null) ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  StatTile(
                    label: 'Livres',
                    value: '${s.livres}',
                    icon: Icons.menu_book_rounded,
                    tint: AppColors.primary,
                  ),
                  StatTile(
                    label: 'Adhérents',
                    value: '${s.adherents}',
                    icon: Icons.people_alt_rounded,
                    tint: AppColors.accent,
                  ),
                  StatTile(
                    label: 'Emprunts en cours',
                    value: '${s.empruntsEnCours}',
                    icon: Icons.swap_horiz_rounded,
                    tint: AppColors.warning,
                  ),
                  StatTile(
                    label: 'En retard',
                    value: '${s.empruntsEnRetard}',
                    icon: Icons.warning_amber_rounded,
                    tint: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionLabel('Highlights'),
              const SizedBox(height: 10),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightRow(
                      icon: Icons.star_rounded,
                      label: 'Livre populaire',
                      value: s.topLivres.isEmpty
                          ? 'Aucun'
                          : '${s.topLivres.first.titre} (${s.topLivres.first.nbEmprunts})',
                    ),
                    const Divider(height: 24),
                    _HighlightRow(
                      icon: Icons.person_rounded,
                      label: 'Adhérent actif',
                      value: s.topAdherents.isEmpty
                          ? 'Aucun'
                          : '${s.topAdherents.first.nom} (${s.topAdherents.first.nbEmprunts})',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
