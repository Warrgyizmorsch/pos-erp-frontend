import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/payment_in.dart';
import '../models/payment_in_payload.dart';
import '../repositories/payment_in_repository.dart';

class PaymentInController extends GetxController {
  final PaymentInRepository _repository;

  PaymentInController(this._repository);

  final RxList<PaymentIn> payments = <PaymentIn>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxString searchQuery = ''.obs;

  final RxList<Customer> availableCustomers = <Customer>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;
  final RxList<Sale> unpaidInvoices = <Sale>[].obs;
  final RxBool isFetchingUnpaid = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
    loadFormDependencies();

    debounce(searchQuery, (_) {
      loadPayments();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      final result = await _repository.getPayments(search: searchQuery.value);
      payments.assignAll(result);
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load Payment-In records',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFormDependencies() async {
    try {
      final custs = await _repository.fetchCustomers();
      final banks = await _repository.fetchBankAccounts();
      availableCustomers.assignAll(custs);
      bankAccounts.assignAll(banks);
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> fetchUnpaidInvoices(String customerId) async {
    if (customerId.isEmpty) {
      unpaidInvoices.clear();
      return;
    }
    try {
      isFetchingUnpaid.value = true;
      final invoices = await _repository.fetchUnpaidInvoices(customerId);
      unpaidInvoices.assignAll(invoices);
    } catch (e) {
      unpaidInvoices.clear();
    } finally {
      isFetchingUnpaid.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<bool> createPayment(PaymentInPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.createPayment(payload);
      Get.snackbar(
        'Success',
        'Payment-In recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPayments();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to record Payment-In',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updatePayment(String id, PaymentInPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.updatePayment(id, payload);
      Get.snackbar(
        'Success',
        'Payment-In updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPayments();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to update Payment-In',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _repository.deletePayment(id);
      Get.snackbar(
        'Success',
        'Payment record deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPayments();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete payment record',
      );
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
