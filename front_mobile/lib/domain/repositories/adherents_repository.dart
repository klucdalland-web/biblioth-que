import 'package:front_mobile/data/models/adherent_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';

/// Contrat adhérents : lecture avec fallback cache hors ligne.
abstract class AdherentsRepository {
  Future<RepositoryResult<List<AdherentModel>>> list({String? search});

  Future<AdherentModel> create({
    required String nom,
    required String contact,
  });

  Future<void> remove(int id);
}
