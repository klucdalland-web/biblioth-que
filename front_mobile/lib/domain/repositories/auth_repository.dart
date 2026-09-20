import 'package:front_mobile/data/models/auth_tokens_model.dart';
import 'package:front_mobile/data/models/user_model.dart';

/// Contrat d'authentification (JWT + profil).
abstract class AuthRepository {
  Future<AuthTokensModel> login({
    required String mail,
    required String password,
  });

  Future<UserModel> me();

  Future<UserModel> updateMe({
    required String nom,
    required String mail,
  });

  Future<void> changePassword({
    required String passwordActuel,
    required String password,
    required String confirmation,
  });

  Future<void> logout(String refreshToken);
}
