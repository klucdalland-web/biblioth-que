import 'package:flutter/material.dart';
import 'package:front_mobile/app/routes/app_routes.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/modules/register/register_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterView extends GetView<RegisterController> {
  RegisterView({super.key});

  final _nomCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _obscure = true.obs;
  final _obscureConfirm = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Text(
                      'BiblioGestion',
                      style: GoogleFonts.fraunces(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez votre compte — Bibliothèque de quartier',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Inscription',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Remplissez le formulaire pour créer votre compte',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              if (controller.errorMessage.value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  controller.errorMessage.value,
                                  style: const TextStyle(color: AppColors.danger),
                                ),
                              );
                            }),
                            TextFormField(
                              controller: _nomCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nom complet',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Nom requis' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _mailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Adresse email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Email requis' : null,
                            ),
                            const SizedBox(height: 14),
                            Obx(
                              () => TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure.value,
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        _obscure.value = !_obscure.value,
                                    icon: Icon(
                                      _obscure.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Mot de passe requis'
                                    : (v.length < 6)
                                        ? '6 caractères minimum'
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Obx(
                              () => TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm.value,
                                decoration: InputDecoration(
                                  labelText: 'Confirmer le mot de passe',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        _obscureConfirm.value = !_obscureConfirm.value,
                                    icon: Icon(
                                      _obscureConfirm.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirmation requise';
                                  }
                                  if (v != _passwordCtrl.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate()) {
                                          return;
                                        }
                                        final ok = await controller.register(
                                          nom: _nomCtrl.text.trim(),
                                          mail: _mailCtrl.text.trim(),
                                          password: _passwordCtrl.text,
                                        );
                                        if (ok) {
                                          await Get.offAllNamed(AppRoutes.shell);
                                        }
                                      },
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Créer mon compte'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Déjà un compte ? Se connecter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
