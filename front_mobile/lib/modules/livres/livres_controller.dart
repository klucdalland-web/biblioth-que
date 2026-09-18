import 'dart:async';

import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/auteur_model.dart';
import 'package:front_mobile/data/models/livre_model.dart';
import 'package:front_mobile/data/repositories/livres_repository.dart';
import 'package:get/get.dart';

class LivresController extends GetxController {
  LivresController(this._repo);

  final LivresRepository _repo;

  final items = <LivreModel>[].obs;
  final auteurs = <AuteurModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final page = 1.obs;
  final totalPages = 1.obs;
  final total = 0.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    load();
    loadAuteurs();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      page.value = 1;
      load();
    });
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _repo.list(
        search: searchQuery.value,
        page: page.value,
        limit: 10,
      );
      items.assignAll(data.items);
      page.value = data.page;
      totalPages.value = data.totalPages;
      total.value = data.total;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAuteurs() async {
    try {
      auteurs.assignAll(await _repo.listAuteurs());
    } catch (_) {
      // silencieux : nécessaire seulement pour le formulaire
    }
  }

  Future<void> nextPage() async {
    if (page.value >= totalPages.value) return;
    page.value++;
    await load();
  }

  Future<void> prevPage() async {
    if (page.value <= 1) return;
    page.value--;
    await load();
  }

  Future<bool> create({
    required String titre,
    required int idAuteur,
    int? annee,
  }) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      await _repo.create(
        titre: titre,
        idAuteur: idAuteur,
        anneePublication: annee,
      );
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

  Future<bool> remove(int id) async {
    try {
      await _repo.remove(id);
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
