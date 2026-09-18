import 'package:flutter/material.dart';
import 'package:front_mobile/app/theme/app_colors.dart';
import 'package:front_mobile/app/widgets/ui_kit.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final AuthController controller;
  late final TextEditingController nomCtrl;
  late final TextEditingController emailCtrl;
  final actuelCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final profileMsg = ''.obs;
  final profileError = ''.obs;
  final passwordMsg = ''.obs;
  final passwordError = ''.obs;
  final savingProfile = false.obs;
  final savingPassword = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
    nomCtrl = TextEditingController(text: controller.user.value?.nom ?? '');
    emailCtrl = TextEditingController(text: controller.user.value?.email ?? '');
  }

  @override
  void dispose() {
    nomCtrl.dispose();
    emailCtrl.dispose();
    actuelCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Obx(() {
        final u = controller.user.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (u?.nom.isNotEmpty == true)
                          ? u!.nom[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u?.nom ?? '—',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          u?.isAdmin == true
                              ? 'Administrateur'
                              : 'Bibliothécaire',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('Informations'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  if (profileError.value.isNotEmpty)
                    ErrorBanner(message: profileError.value),
                  if (profileMsg.value.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        profileMsg.value,
                        style: const TextStyle(color: AppColors.success),
                      ),
                    ),
                  TextField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    child: Text(
                      u?.isAdmin == true
                          ? 'Administrateur'
                          : 'Bibliothécaire',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: savingProfile.value
                        ? null
                        : () async {
                            try {
                              savingProfile.value = true;
                              profileError.value = '';
                              profileMsg.value = '';
                              await Get.find<AuthRepository>().updateMe(
                                nom: nomCtrl.text.trim(),
                                mail: emailCtrl.text.trim(),
                              );
                              await controller.refreshProfile();
                              profileMsg.value = 'Profil mis à jour';
                            } on ApiException catch (e) {
                              profileError.value = e.message;
                            } catch (e) {
                              profileError.value = e.toString();
                            } finally {
                              savingProfile.value = false;
                            }
                          },
                    child: savingProfile.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enregistrer le profil'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionLabel('Mot de passe'),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  if (passwordError.value.isNotEmpty)
                    ErrorBanner(message: passwordError.value),
                  if (passwordMsg.value.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        passwordMsg.value,
                        style: const TextStyle(color: AppColors.success),
                      ),
                    ),
                  TextField(
                    controller: actuelCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe actuel',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmation',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: savingPassword.value
                        ? null
                        : () async {
                            if (newCtrl.text != confirmCtrl.text) {
                              passwordError.value =
                                  'Les mots de passe ne correspondent pas';
                              return;
                            }
                            try {
                              savingPassword.value = true;
                              passwordError.value = '';
                              passwordMsg.value = '';
                              await Get.find<AuthRepository>().changePassword(
                                passwordActuel: actuelCtrl.text,
                                password: newCtrl.text,
                                confirmation: confirmCtrl.text,
                              );
                              passwordMsg.value =
                                  'Mot de passe modifié. Reconnectez-vous.';
                              await Future<void>.delayed(
                                const Duration(milliseconds: 1200),
                              );
                              await controller.logout();
                            } on ApiException catch (e) {
                              passwordError.value = e.message;
                            } catch (e) {
                              passwordError.value = e.toString();
                            } finally {
                              savingPassword.value = false;
                            }
                          },
                    child: savingPassword.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Modifier le mot de passe'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      }),
    );
  }
}
