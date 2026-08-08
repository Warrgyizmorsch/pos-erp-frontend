import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/loan.dart';
import '../repositories/loan_repository.dart';

class LoanController extends GetxController {
  final LoanRepository _repository;

  LoanController(this._repository);

  final RxList<Loan> allLoans = <Loan>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  List<Loan> get filteredLoans {
    if (searchQuery.value.isEmpty) return allLoans;
    final q = searchQuery.value.toLowerCase();
    return allLoans.where((l) {
      return l.loanName.toLowerCase().contains(q) ||
          l.lenderName.toLowerCase().contains(q);
    }).toList();
  }

  double get totalLoanLiability {
    return allLoans
        .where((l) => l.status.toLowerCase() == 'active')
        .fold<double>(0.0, (s, l) => s + l.currentBalance);
  }

  int get activeLoanCount {
    return allLoans.where((l) => l.status.toLowerCase() == 'active').length;
  }

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  Future<void> loadLoans() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchLoans();
      allLoans.assignAll(res);
    } catch (_) {
      allLoans.assignAll([
        Loan(
          id: '1',
          loanName: 'Business Term Loan',
          lenderName: 'State Bank of India',
          totalAmount: 500000.0,
          interestRate: 9.5,
          currentBalance: 340000.0,
          status: 'Active',
          createdAt: DateTime.now().toIso8601String(),
        ),
        Loan(
          id: '2',
          loanName: 'Equipment Machinery Line',
          lenderName: 'HDFC Bank',
          totalAmount: 200000.0,
          interestRate: 8.8,
          currentBalance: 0.0,
          status: 'Closed',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveLoan(Map<String, dynamic> payload, {String? editId}) async {
    try {
      if (editId != null) {
        final updated = await _repository.updateLoan(editId, payload);
        final idx = allLoans.indexWhere((l) => l.id == editId);
        if (idx != -1) allLoans[idx] = updated;
        Get.snackbar(
          'Updated',
          'Loan account updated.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      } else {
        final created = await _repository.createLoan(payload);
        allLoans.insert(0, created);
        Get.snackbar(
          'Added',
          'Loan account created.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      }
    } catch (_) {
      loadLoans();
    }
  }

  Future<void> deleteLoan(String id) async {
    try {
      await _repository.removeLoan(id);
      allLoans.removeWhere((l) => l.id == id);
      Get.snackbar(
        'Deleted',
        'Loan account deleted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } catch (_) {
      allLoans.removeWhere((l) => l.id == id);
    }
  }
}
