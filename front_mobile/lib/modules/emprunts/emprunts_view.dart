import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/modules/emprunts/emprunts_controller.dart';
import 'package:get/get.dart';

class EmpruntsView extends GetView<EmpruntsController> {
  const EmpruntsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel emprunt'),
      ),
      body: Obx(() {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('En cours'),
                      selected: controller.tab.value == EmpruntsTab.enCours,
                      onSelected: (_) =>
                          controller.setTab(EmpruntsTab.enCours),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('En retard'),
                      selected: controller.tab.value == EmpruntsTab.enRetard,
                      onSelected: (_) =>
                          controller.setTab(EmpruntsTab.enRetard),
                    ),
                  ),
                ],
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
                                icon: Icons.swap_horiz,
                                title: 'Aucun emprunt',
                                subtitle: 'Aucun emprunt pour cet onglet',
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: controller.items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final e = controller.items[index];
                              return AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            e.livreTitre ?? 'Livre',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        _badgeFor(e.statut),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      e.adherentNom ?? 'Adhérent',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Emprunté : ${_fmt(e.dateEmprunt)} · Retour prévu : ${_fmt(e.dateRetourPrevue)}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (e.canReturn) ...[
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: OutlinedButton(
                                          onPressed: () => _confirmRetour(e.id),
                                          child: const Text('Retour'),
                                        ),
                                      ),
                                    ],
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

  StatusBadge _badgeFor(String statut) {
    switch (statut) {
      case 'en_retard':
        return StatusBadge.danger('En retard');
      case 'retourne':
        return StatusBadge.success('Retourné');
      default:
        return StatusBadge.warning('En cours');
    }
  }

  String _fmt(String? value) {
    if (value == null || value.isEmpty) return '—';
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  Future<void> _confirmRetour(int id) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Marquer comme retourné ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Confirmer')),
        ],
      ),
    );
    if (ok == true) await controller.retour(id);
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    await controller.loadFormData();
    int? idAdherent =
        controller.adherents.isNotEmpty ? controller.adherents.first.id : null;
    int? idLivre = controller.livresDisponibles.isNotEmpty
        ? controller.livresDisponibles.first.id
        : null;
    final date = DateTime.now().add(const Duration(days: 14));
    final dateCtrl = TextEditingController(
      text: date.toIso8601String().substring(0, 10),
    );
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
                      'Nouvel emprunt',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    if (localError != null) ErrorBanner(message: localError!),
                    DropdownButtonFormField<int>(
                      initialValue: idAdherent,
                      decoration: const InputDecoration(labelText: 'Adhérent'),
                      items: controller.adherents
                          .map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.nom),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => idAdherent = v),
                      validator: (v) => v == null ? 'Adhérent requis' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: idLivre,
                      decoration:
                          const InputDecoration(labelText: 'Livre disponible'),
                      items: controller.livresDisponibles
                          .map(
                            (l) => DropdownMenuItem(
                              value: l.id,
                              child: Text(l.titre),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => idLivre = v),
                      validator: (v) => v == null ? 'Livre requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Date retour prévue (AAAA-MM-JJ)',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Date requise' : null,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                final ok = await controller.create(
                                  idAdherent: idAdherent!,
                                  idLivre: idLivre!,
                                  dateRetourPrevue: dateCtrl.text.trim(),
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
