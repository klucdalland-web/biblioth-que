import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/stats_model.dart';
import 'package:front_mobile/domain/repositories/stats_repository.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardController(this._repo);

  final StatsRepository _repo;

  final stats = Rxn<StatsModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isOfflineData = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.getStats();
      stats.value = result.data;
      isOfflineData.value = result.fromCache;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isOfflineData.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isOfflineData.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
