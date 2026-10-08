import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';

/// Controller pour l'écran d'inscription (délègue à AuthController).
class RegisterController extends GetxController {
  RegisterController(this._authController);

  final AuthController _authController;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<bool> register({
    required String nom,
    required String mail,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final success = await _authController.register(
      nom: nom,
      mail: mail,
      password: password,
    );

    errorMessage.value = _authController.errorMessage.value;
    isLoading.value = false;

    return success;
  }
}
