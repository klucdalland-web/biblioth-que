import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/modules/adherents/adherents_controller.dart';
import 'package:get/get.dart';

class AdherentsView extends GetView<AdherentsController> {
  const AdherentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nouvel adhérent'),
      ),
      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchField(
                controller: searchCtrl,
                hint: 'Rechercher un adhérent…',
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
                                icon: Icons.people_outline,
                                title: 'Aucun adhérent',
                                subtitle: 'Ajoutez un adhérent pour commencer',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: controller.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final a = controller.items[index];
                              return AppCard(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      foregroundColor: AppColors.primary,
                                      child: Text(
                                        a.nom.isNotEmpty
                                            ? a.nom[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a.nom,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            a.contact,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _confirmDelete(a.id),
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
          ],
        );
      }),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer cet adhérent ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await controller.remove(id);
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
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
                      'Nouvel adhérent',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    if (localError != null) ErrorBanner(message: localError!),
                    TextFormField(
                      controller: nomCtrl,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: prenomCtrl,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: contactCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Contact / email'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Contact requis' : null,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final nom =
                                    '${nomCtrl.text.trim()} ${prenomCtrl.text.trim()}'
                                        .trim();
                                final ok = await controller.create(
                                  nom: nom,
                                  contact: contactCtrl.text.trim(),
                                );
                                if (ok) {
                                  Get.back();
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
