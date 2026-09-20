import 'package:front_mobile/data/datasources/remote/users_remote_data_source.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/domain/repositories/users_repository.dart';

/// Implémentation utilisateurs admin (online-only).
class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl(this._remote);

  final UsersRemoteDataSource _remote;

  @override
  Future<List<UserModel>> list() => _remote.list();

  @override
  Future<UserModel> create({
    required String nom,
    required String mail,
    required String password,
    required String role,
  }) =>
      _remote.create(
        nom: nom,
        mail: mail,
        password: password,
        role: role,
      );

  @override
  Future<UserModel> update({
    required int id,
    required String nom,
    required String mail,
    required String role,
  }) =>
      _remote.update(id: id, nom: nom, mail: mail, role: role);

  @override
  Future<void> remove(int id) => _remote.remove(id);
}
