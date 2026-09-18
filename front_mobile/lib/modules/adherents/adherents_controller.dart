import 'dart:async';

import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/models/adherent_model.dart';
import 'package:front_mobile/data/repositories/adherents_repository.dart';
import 'package:get/get.dart';

class AdherentsController extends GetxController {
  AdherentsController(this._repo);

  final AdherentsRepository _repo;

  final items = <AdherentModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), load);
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      items.assignAll(await _repo.list(search: searchQuery.value));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create({required String nom, required String contact}) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      await _repo.create(nom: nom, contact: contact);
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
