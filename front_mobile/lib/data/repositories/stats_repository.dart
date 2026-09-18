import 'package:dio/dio.dart';
import 'package:front_mobile/core/constants/api_constants.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/data/models/stats_model.dart';

class StatsRepository {
  StatsRepository(this._api);

  final ApiClient _api;

  Future<StatsModel> getStats() async {
    try {
      final res = await _api.dio.get(ApiConstants.stats);
      final data = _api.unwrap(res);
      return StatsModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      _api.throwFromDio(e);
    }
  }
}
