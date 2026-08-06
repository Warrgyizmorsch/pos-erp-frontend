import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/payment_out.dart';
import '../models/payment_out_payload.dart';
import '../repositories/payment_out_repository.dart';

class PaymentOutController extends GetxController {
  final PaymentOutRepository _repository;

  PaymentOutController(this._repository);

  final RxList<PaymentOut> payments = <PaymentOut>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isFetchingUnpaid = false.obs;

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 20;

  // Form dependencies & master lists
  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;
  final RxList<Purchase> unpaidPurchases = <Purchase>[].obs;

  // Form State
  final Rxn<Supplier> selectedSupplier = Rxn<Supplier>();
  final RxDouble amountPaid = 0.0.obs;
  final RxString paymentMode = 'Cash'.obs;
  final RxnString bankAccountId = RxnString();
  final RxString date = DateTime.now().toIso8601String().split('T')[0].obs;
  final Rxn<Purchase> selectedPurchase = Rxn<Purchase>();
  final RxString description = ''.obs;
  final RxString referenceNo = ''.obs;
  final RxnString editingPaymentId = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPayments();
    loadFormDependencies();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadPayments();
    }, time: const Duration(milliseconds: 400));

    // Reactively fetch unpaid purchases when supplier changes
    ever(selectedSupplier, (supplier) {
      if (supplier != null) {
        fetchUnpaidPurchases(supplier.id);
      } else {
        unpaidPurchases.clear();
        selectedPurchase.value = null;
      }
    });
  }

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      final result = await _repository.getPayments(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
      );

      payments.assignAll(result.data);
      if (result.pagination != null) {
        totalPages.value = result.pagination!.pages;
      } else {
        totalPages.value = 1;
      }
    } catch (e) {
      payments.clear();
      if (e is AppException &&
          (e.statusCode == 404 ||
              e.message.toLowerCase().contains('not found'))) {
        // Silently treat as empty list
      } else {
        showErrorSnackbar(
          e is AppException ? e.message : 'Failed to load payments.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFormDependencies() async {
    try {
      final supps = await _repository.fetchSuppliers();
      final banks = await _repository.fetchBankAccounts();
      suppliers.assignAll(supps);
      bankAccounts.assignAll(banks);
    } catch (e) {
      // Non-blocking
    }
  }

  Future<void> fetchUnpaidPurchases(String supplierId) async {
    try {
      isFetchingUnpaid.value = true;
      final bills = await _repository.fetchUnpaidPurchases(supplierId);
      unpaidPurchases.assignAll(bills);
    } catch (e) {
      unpaidPurchases.clear();
    } finally {
      isFetchingUnpaid.value = false;
    }
  }

  void resetForm() {
    selectedSupplier.value = null;
    amountPaid.value = 0.0;
    paymentMode.value = 'Cash';
    bankAccountId.value = null;
    date.value = DateTime.now().toIso8601String().split('T')[0];
    selectedPurchase.value = null;
    description.value = '';
    referenceNo.value = '';
    editingPaymentId.value = null;
    unpaidPurchases.clear();
  }

  void setEditForm(PaymentOut payment) {
    editingPaymentId.value = payment.id;
    if (payment.partyId is Supplier) {
      selectedSupplier.value = payment.partyId as Supplier;
    } else {
      selectedSupplier.value = suppliers.firstWhereOrNull(
        (s) => s.id == payment.partyId,
      );
    }
    amountPaid.value = payment.amountPaid;
    paymentMode.value = payment.paymentMode;
    bankAccountId.value = payment.cashBankAccountId;
    date.value = payment.date.split('T')[0];
    description.value = payment.description ?? '';
    referenceNo.value = payment.referenceNo ?? '';

    if (selectedSupplier.value != null) {
      fetchUnpaidPurchases(selectedSupplier.value!.id);
    }
  }

  void selectUnpaidPurchase(Purchase purchase) {
    if (selectedPurchase.value?.id == purchase.id) {
      selectedPurchase.value = null;
    } else {
      selectedPurchase.value = purchase;
      amountPaid.value = purchase.dueAmount > 0
          ? purchase.dueAmount
          : purchase.totalAmount - purchase.amountPaid;
    }
  }

  Future<bool> savePayment() async {
    if (selectedSupplier.value == null) {
      showErrorSnackbar('Please select a supplier.');
      return false;
    }
    if (amountPaid.value <= 0) {
      showErrorSnackbar('Amount paid must be greater than 0.');
      return false;
    }
    if (paymentMode.value.toLowerCase() != 'cash' &&
        (bankAccountId.value == null || bankAccountId.value!.isEmpty)) {
      showErrorSnackbar('Bank account is required for non-cash payments.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = PaymentOutPayload(
        partyId: selectedSupplier.value!.id,
        amountPaid: amountPaid.value,
        paymentMode: paymentMode.value,
        cashBankAccountId: bankAccountId.value,
        date: date.value,
        linkedPurchaseId: selectedPurchase.value?.id,
        description: description.value.trim(),
        referenceNo: referenceNo.value.trim(),
      );

      if (editingPaymentId.value != null) {
        await _repository.updatePayment(editingPaymentId.value!, payload);
        Get.snackbar(
          'Success',
          'Payment-Out updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _repository.createPayment(payload);
        Get.snackbar(
          'Success',
          'Payment-Out recorded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      loadPayments();
      resetForm();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to save payment record.',
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
        'Payment-Out record deleted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPayments();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete payment record.',
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadPayments();
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
