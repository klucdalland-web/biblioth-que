import 'package:front_mobile/data/models/stats_model.dart';
import 'package:front_mobile/domain/models/repository_result.dart';

/// Contrat statistiques dashboard : lecture avec fallback cache hors ligne.
abstract class StatsRepository {
  Future<RepositoryResult<StatsModel>> getStats();
}
