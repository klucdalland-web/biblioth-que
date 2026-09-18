import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/modules/livres/livres_controller.dart';
import 'package:get/get.dart';

class LivresView extends GetView<LivresController> {
  const LivresView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau livre'),
      ),
      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchField(
                controller: searchCtrl,
                hint: 'Rechercher un livre…',
                onChanged: controller.onSearchChanged,
              ),
            ),
            if (controller.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(
                  message: controller.errorMessage.value,
                  onRetry: controller.load,
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: controller.isLoading.value && controller.items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          LoadingView(),
                        ],
                      )
                    : controller.items.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              EmptyState(
                                icon: Icons.menu_book_outlined,
                                title: 'Aucun livre trouvé',
                                subtitle: 'Ajoutez un livre ou modifiez la recherche',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: controller.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final livre = controller.items[index];
                              return AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            livre.titre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            [
                                              livre.auteurNom ?? 'Auteur inconnu',
                                              if (livre.anneePublication != null)
                                                '${livre.anneePublication}',
                                            ].join(' · '),
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          livre.isDisponible
                                              ? StatusBadge.success('Disponible')
                                              : StatusBadge.warning('Emprunté'),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Supprimer',
                                      onPressed: () =>
                                          _confirmDelete(context, livre.id),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
            if (controller.totalPages.value > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Page ${controller.page.value}/${controller.totalPages.value} (${controller.total.value})',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: controller.page.value > 1
                          ? controller.prevPage
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed:
                          controller.page.value < controller.totalPages.value
                              ? controller.nextPage
                              : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer ce livre ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await controller.remove(id);
      if (success) {
        Get.snackbar('OK', 'Livre supprimé', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    await controller.loadAuteurs();
    final titreCtrl = TextEditingController();
    final anneeCtrl = TextEditingController();
    int? selectedAuteur =
        controller.auteurs.isNotEmpty ? controller.auteurs.first.id : null;
    final formKey = GlobalKey<FormState>();
    String? localError;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nouveau livre',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    if (localError != null) ...[
                      ErrorBanner(message: localError!),
                    ],
                    TextFormField(
                      controller: titreCtrl,
                      decoration: const InputDecoration(labelText: 'Titre'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedAuteur,
                      decoration: const InputDecoration(labelText: 'Auteur'),
                      items: controller.auteurs
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.nom),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedAuteur = v),
                      validator: (v) => v == null ? 'Auteur requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: anneeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Année (optionnel)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                if (selectedAuteur == null) return;
                                final annee = int.tryParse(anneeCtrl.text.trim());
                                final ok = await controller.create(
                                  titre: titreCtrl.text.trim(),
                                  idAuteur: selectedAuteur!,
                                  annee: annee,
                                );
                                if (ok) {
                                  Get.back();
                                  Get.snackbar(
                                    'OK',
                                    'Livre ajouté',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } else {
                                  setState(() {
                                    localError = controller.errorMessage.value;
                                  });
                                }
                              },
                        child: controller.isSaving.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
