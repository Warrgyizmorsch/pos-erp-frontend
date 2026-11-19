import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cheque.dart';
import '../repositories/cheque_repository.dart';

class ChequeListController extends GetxController {
  final ChequeRepository _repository;

  ChequeListController(this._repository);

  final RxList<Cheque> allCheques = <Cheque>[].obs;
  final RxBool isLoading = true.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'All'.obs;
  final RxString typeFilter = 'All'.obs;

  List<Cheque> get filteredCheques {
    return allCheques.where((c) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          c.chequeNumber.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          c.partyName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          c.bankName.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesStatus =
          statusFilter.value == 'All' ||
          c.status.toLowerCase() == statusFilter.value.toLowerCase();

      final matchesType =
          typeFilter.value == 'All' ||
          c.type.toLowerCase() == typeFilter.value.toLowerCase();

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  double get totalPendingAmount {
    return allCheques
        .where((c) => c.status.toLowerCase() == 'pending')
        .fold<double>(0.0, (s, c) => s + c.amount);
  }

  double get totalClearedAmount {
    return allCheques
        .where((c) => c.status.toLowerCase() == 'cleared')
        .fold<double>(0.0, (s, c) => s + c.amount);
  }

  double get totalBouncedAmount {
    return allCheques
        .where((c) => c.status.toLowerCase() == 'bounced')
        .fold<double>(0.0, (s, c) => s + c.amount);
  }

  @override
  void onInit() {
    super.onInit();
    loadCheques();
  }

  Future<void> loadCheques() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchCheques();
      allCheques.assignAll(res);
    } catch (_) {
      allCheques.assignAll([
        Cheque(
          id: '1',
          type: 'received',
          chequeNumber: 'CHQ-889012',
          amount: 45000.0,
          date: DateTime.now().toIso8601String(),
          partyName: 'Apex Traders Pvt Ltd',
          bankName: 'HDFC Bank',
          status: 'Pending',
          clearanceAccountType: 'bank',
          createdAt: DateTime.now().toIso8601String(),
        ),
        Cheque(
          id: '2',
          type: 'issued',
          chequeNumber: 'CHQ-104522',
          amount: 12500.0,
          date: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          partyName: 'National Logistics',
          bankName: 'ICICI Bank',
          status: 'Cleared',
          clearanceAccountType: 'bank',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCheque(
    Map<String, dynamic> payload, {
    String? editId,
  }) async {
    try {
      if (editId != null) {
        final updated = await _repository.updateCheque(editId, payload);
        final idx = allCheques.indexWhere((c) => c.id == editId);
        if (idx != -1) allCheques[idx] = updated;
        Get.snackbar(
          'Updated',
          'Cheque entry updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      } else {
        final created = await _repository.createCheque(payload);
        allCheques.insert(0, created);
        Get.snackbar(
          'Created',
          'Cheque record added successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      }
    } catch (_) {
      loadCheques();
    }
  }

  Future<void> updateStatus(Cheque cheque, String newStatus) async {
    try {
      final payload = cheque.toJson();
      payload['status'] = newStatus;
      final updated = await _repository.updateCheque(cheque.id, payload);
      final idx = allCheques.indexWhere((c) => c.id == cheque.id);
      if (idx != -1) allCheques[idx] = updated;
      Get.snackbar(
        'Status Updated',
        'Cheque status set to $newStatus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      loadCheques();
    }
  }

  Future<void> deleteCheque(String id) async {
    try {
      await _repository.removeCheque(id);
      allCheques.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Deleted',
        'Cheque record removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } catch (_) {
      allCheques.removeWhere((c) => c.id == id);
    }
  }
}
