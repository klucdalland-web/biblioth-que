import 'package:front_mobile/data/models/user_model.dart';

/// Contrat gestion utilisateurs (admin).
abstract class UsersRepository {
  Future<List<UserModel>> list();

  Future<UserModel> create({
    required String nom,
    required String mail,
    required String password,
    required String role,
  });

  Future<UserModel> update({
    required int id,
    required String nom,
    required String mail,
    required String role,
  });

  Future<void> remove(int id);
}
