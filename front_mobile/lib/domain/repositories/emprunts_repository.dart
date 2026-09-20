import 'package:front_mobile/data/models/emprunt_model.dart';

/// Contrat emprunts (mutations online-only).
abstract class EmpruntsRepository {
  Future<List<EmpruntModel>> list();

  Future<List<EmpruntModel>> listRetard();

  Future<EmpruntModel> create({
    required int idAdherent,
    required int idLivre,
    required String dateRetourPrevue,
  });

  Future<void> retour(int id);
}
