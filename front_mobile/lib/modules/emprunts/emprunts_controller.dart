import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/adherent_model.dart';
import 'package:front_mobile/data/models/emprunt_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';
import 'package:front_mobile/domain/repositories/adherents_repository.dart';
import 'package:front_mobile/domain/repositories/emprunts_repository.dart';
import 'package:front_mobile/domain/repositories/livres_repository.dart';
import 'package:get/get.dart';

enum EmpruntsTab { enCours, enRetard }

class EmpruntsController extends GetxController {
  EmpruntsController(this._empruntsRepo, this._adherentsRepo, this._livresRepo);

  final EmpruntsRepository _empruntsRepo;
  final AdherentsRepository _adherentsRepo;
  final LivresRepository _livresRepo;

  final items = <EmpruntModel>[].obs;
  final adherents = <AdherentModel>[].obs;
  final livresDisponibles = <LivreModel>[].obs;
  final tab = EmpruntsTab.enCours.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    loadFormData();
  }

  Future<void> loadFormData() async {
    try {
      final adherentsResult = await _adherentsRepo.list();
      final livresResult = await _livresRepo.list(page: 1, limit: 200);
      adherents.assignAll(adherentsResult.data);
      livresDisponibles.assignAll(
        livresResult.data.items.where((l) => l.isDisponible).toList(),
      );
    } catch (_) {}
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (tab.value == EmpruntsTab.enRetard) {
        items.assignAll(await _empruntsRepo.listRetard());
      } else {
        final all = await _empruntsRepo.list();
        items.assignAll(
          all.where(
            (e) => e.dateRetourReelle == null || e.dateRetourReelle!.isEmpty,
          ),
        );
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(EmpruntsTab value) {
    if (tab.value == value) return;
    tab.value = value;
    load();
  }

  Future<bool> create({
    required int idAdherent,
    required int idLivre,
    required String dateRetourPrevue,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      await _empruntsRepo.create(
        idAdherent: idAdherent,
        idLivre: idLivre,
        dateRetourPrevue: dateRetourPrevue,
      );
      await loadFormData();
      await load();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> retour(int id) async {
    try {
      errorMessage.value = '';
      await _empruntsRepo.retour(id);
      await loadFormData();
      await load();
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
