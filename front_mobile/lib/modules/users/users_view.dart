import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/modules/users/users_controller.dart';
import 'package:get/get.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nouvel utilisateur'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const LoadingView();
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              if (controller.errorMessage.value.isNotEmpty)
                ErrorBanner(
                  message: controller.errorMessage.value,
                  onRetry: controller.load,
                ),
              if (controller.items.isEmpty)
                const EmptyState(
                  icon: Icons.group_outlined,
                  title: 'Aucun utilisateur',
                )
              else
                ...controller.items.map((u) {
                  final isSelf = u.id == controller.currentUserId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                            child: Text(
                              u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSelf ? '${u.nom} (vous)' : u.nom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusBadge.neutral(
                                  u.isAdmin ? 'Administrateur' : 'Bibliothécaire',
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEditSheet(u),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          if (!isSelf)
                            IconButton(
                              onPressed: () => _confirmDelete(u.id),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer cet utilisateur ?'),
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

  Future<void> _showCreateSheet() async {
    final nomCtrl = TextEditingController();
    final mailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'bibliothecaire';
    final formKey = GlobalKey<FormState>();
    String? localError;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return _sheet(
            title: 'Nouvel utilisateur',
            localError: localError,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Nom trop court' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    validator: (v) =>
                        (v == null || v.length < 6) ? '6 caractères min.' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: const [
                      DropdownMenuItem(
                        value: 'bibliothecaire',
                        child: Text('Bibliothécaire'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrateur'),
                      ),
                    ],
                    onChanged: (v) => setState(() => role = v ?? role),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final ok = await controller.create(
                                nom: nomCtrl.text.trim(),
                                mail: mailCtrl.text.trim(),
                                password: passwordCtrl.text,
                                role: role,
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
                          : const Text('Créer'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _showEditSheet(UserModel user) async {
    final nomCtrl = TextEditingController(text: user.nom);
    final mailCtrl = TextEditingController(text: user.email);
    String role = user.role;
    final formKey = GlobalKey<FormState>();
    String? localError;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return _sheet(
            title: 'Modifier l’utilisateur',
            localError: localError,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Nom trop court' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: mailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email requis' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: const [
                      DropdownMenuItem(
                        value: 'bibliothecaire',
                        child: Text('Bibliothécaire'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrateur'),
                      ),
                    ],
                    onChanged: (v) => setState(() => role = v ?? role),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final ok = await controller.updateUser(
                                id: user.id,
                                nom: nomCtrl.text.trim(),
                                mail: mailCtrl.text.trim(),
                                role: role,
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
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheet({
    required String title,
    required Widget child,
    String? localError,
  }) {
    return Builder(
      builder: (context) {
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (localError != null) ErrorBanner(message: localError),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}
