import 'package:front_mobile/data/models/auteur_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';

/// Contrat livres : lecture avec fallback cache hors ligne.
abstract class LivresRepository {
  Future<RepositoryResult<PaginatedLivres>> list({
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<RepositoryResult<List<AuteurModel>>> listAuteurs();

  Future<LivreModel> create({
    required String titre,
    required int idAuteur,
    int? anneePublication,
  });

  Future<void> remove(int id);
}
