import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/stats_model.dart';
import 'package:front_mobile/data/repositories/stats_repository.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  DashboardController(this._repo);

  final StatsRepository _repo;

  final stats = Rxn<StatsModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      stats.value = await _repo.getStats();
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
