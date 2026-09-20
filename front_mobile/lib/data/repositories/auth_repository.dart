import 'package:front_mobile/data/datasources/remote/auth_remote_data_source.dart';
import 'package:front_mobile/data/models/auth_tokens_model.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/domain/repositories/auth_repository.dart';

/// Implémentation auth : délègue à [AuthRemoteDataSource] (pas de Dio ici).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthTokensModel> login({
    required String mail,
    required String password,
  }) =>
      _remote.login(mail: mail, password: password);

  @override
  Future<UserModel> me() => _remote.me();

  @override
  Future<UserModel> updateMe({
    required String nom,
    required String mail,
  }) =>
      _remote.updateMe(nom: nom, mail: mail);

  @override
  Future<void> changePassword({
    required String passwordActuel,
    required String password,
    required String confirmation,
  }) =>
      _remote.changePassword(
        passwordActuel: passwordActuel,
        password: password,
        confirmation: confirmation,
      );

  @override
  Future<void> logout(String refreshToken) => _remote.logout(refreshToken);
}
