import 'package:front_mobile/data/datasources/remote/emprunts_remote_data_source.dart';
import 'package:front_mobile/data/models/emprunt_model.dart';
import 'package:front_mobile/domain/repositories/emprunts_repository.dart';

/// Implémentation emprunts (online-only).
class EmpruntsRepositoryImpl implements EmpruntsRepository {
  EmpruntsRepositoryImpl(this._remote);

  final EmpruntsRemoteDataSource _remote;

  @override
  Future<List<EmpruntModel>> list() => _remote.list();

  @override
  Future<List<EmpruntModel>> listRetard() => _remote.listRetard();

  @override
  Future<EmpruntModel> create({
    required int idAdherent,
    required int idLivre,
    required String dateRetourPrevue,
  }) =>
      _remote.create(
        idAdherent: idAdherent,
        idLivre: idLivre,
        dateRetourPrevue: dateRetourPrevue,
      );

  @override
  Future<void> retour(int id) => _remote.retour(id);
}
