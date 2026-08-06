import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/purchase_return.dart';
import '../models/purchase_return_item.dart';
import '../models/purchase_return_payload.dart';
import '../repositories/purchase_return_repository.dart';

class PurchaseReturnController extends GetxController {
  final PurchaseReturnRepository _repository;

  PurchaseReturnController(this._repository);

  // Mode: 'list' | 'create'
  final RxString viewMode = 'list'.obs;

  // List View State
  final RxList<PurchaseReturn> returns = <PurchaseReturn>[].obs;
  final RxBool isLoadingList = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString refundFilter = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 15;

  // Detail View State
  final Rxn<PurchaseReturn> selectedReturn = Rxn<PurchaseReturn>();
  final RxBool isLoadingDetail = false.obs;

  // Master Dependencies
  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;
  final RxList<Purchase> supplierBills = <Purchase>[].obs;
  final RxBool isFetchingBills = false.obs;
  final RxBool isFetchingItems = false.obs;

  // Form State
  final Rxn<Supplier> selectedSupplier = Rxn<Supplier>();
  final Rxn<Purchase> selectedBill = Rxn<Purchase>();
  final RxString returnDate = DateTime.now()
      .toIso8601String()
      .split('T')[0]
      .obs;
  final RxString stateOfSupply = ''.obs;
  final RxList<PurchaseReturnItem> formItems = <PurchaseReturnItem>[].obs;
  final RxString refundType = 'keep_as_debit'.obs;
  final RxString paymentMode = 'Cash'.obs;
  final RxnString cashBankAccountId = RxnString();
  final RxString referenceNo = ''.obs;
  final RxString notes = ''.obs;
  final RxBool roundOff = false.obs;
  final RxBool isSubmitting = false.obs;

  // Metrics
  double get listTotalReturns => returns.fold(
    0.0,
    (sum, item) => item.status != 'cancelled' ? sum + item.grandTotal : sum,
  );

  double get listTotalRefunded => returns.fold(
    0.0,
    (sum, item) =>
        item.status != 'cancelled' ? sum + item.refundReceivedAmount : sum,
  );

  double get listTotalDebit => returns.fold(
    0.0,
    (sum, item) => item.status != 'cancelled' ? sum + item.debitBalance : sum,
  );

  // Calculation getters for form
  double get formSubtotal =>
      formItems.fold(0.0, (sum, i) => sum + (i.returnQty * i.purchasePrice));

  double get formTotalDiscount =>
      formItems.fold(0.0, (sum, i) => sum + (i.discountAmount * i.returnQty));

  double get formTotalTax => formItems.fold(0.0, (sum, i) {
    final base =
        (i.returnQty * i.purchasePrice) - (i.discountAmount * i.returnQty);
    return sum + ((base * i.taxPercent) / 100);
  });

  double get formRawGrandTotal =>
      formSubtotal - formTotalDiscount + formTotalTax;

  double get formFinalGrandTotal =>
      roundOff.value ? formRawGrandTotal.roundToDouble() : formRawGrandTotal;

  double get formRoundOffValue => formFinalGrandTotal - formRawGrandTotal;

  double get formRefundReceivedAmount =>
      refundType.value == 'refund_received' ? formFinalGrandTotal : 0.0;

  double get formDebitBalance =>
      refundType.value != 'refund_received' ? formFinalGrandTotal : 0.0;

  @override
  void onInit() {
    super.onInit();
    loadReturns();
    loadFormDependencies();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadReturns();
    }, time: const Duration(milliseconds: 300));

    ever(statusFilter, (_) {
      currentPage.value = 1;
      loadReturns();
    });

    ever(refundFilter, (_) {
      currentPage.value = 1;
      loadReturns();
    });

    ever(selectedSupplier, (supplier) {
      if (supplier != null) {
        onSupplierSelected(supplier);
      } else {
        supplierBills.clear();
        selectedBill.value = null;
        formItems.clear();
      }
    });

    ever(selectedBill, (bill) {
      if (bill != null) {
        onBillSelected(bill);
      } else {
        formItems.clear();
      }
    });
  }

  Future<void> loadReturns() async {
    try {
      isLoadingList.value = true;
      final result = await _repository.getReturns(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
        status: statusFilter.value,
        refundType: refundFilter.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      returns.assignAll(result.data);
      if (result.pagination != null) {
        totalPages.value = result.pagination!.pages;
      } else {
        totalPages.value = 1;
      }
    } catch (e) {
      returns.clear();
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load Debit Notes.',
      );
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> loadFormDependencies() async {
    try {
      final supps = await _repository.fetchSuppliers();
      final banks = await _repository.fetchBankAccounts();
      suppliers.assignAll(supps);
      bankAccounts.assignAll(banks);
      if (banks.isNotEmpty) {
        cashBankAccountId.value =
            banks.first['_id']?.toString() ?? banks.first['id']?.toString();
      }
    } catch (_) {}
  }

  Future<void> onSupplierSelected(Supplier supplier) async {
    try {
      isFetchingBills.value = true;
      selectedBill.value = null;
      formItems.clear();
      final bills = await _repository.fetchUnreturnedPurchases(supplier.id);
      supplierBills.assignAll(bills);
    } catch (_) {
      supplierBills.clear();
    } finally {
      isFetchingBills.value = false;
    }
  }

  Future<void> onBillSelected(Purchase purchase) async {
    try {
      isFetchingItems.value = true;
      formItems.clear();
      stateOfSupply.value = purchase.stateOfSupply ?? '';

      final res = await _repository.fetchReturnableItems(purchase.id);
      final Map<String, dynamic> dataMap = res['data'] is Map<String, dynamic>
          ? res['data']
          : res;
      final List itemsRaw = dataMap['items'] as List? ?? [];

      final items = <PurchaseReturnItem>[];
      for (final i in itemsRaw) {
        if (i is Map<String, dynamic>) {
          final pQty = (i['purchasedQty'] as num?)?.toDouble() ?? 0.0;
          final aRet = (i['alreadyReturnedQty'] as num?)?.toDouble() ?? 0.0;
          final returnable =
              (i['returnableQty'] as num?)?.toDouble() ?? (pQty - aRet);

          final discTot = (i['discountAmount'] as num?)?.toDouble() ?? 0.0;
          final unitDisc = pQty > 0 ? discTot / pQty : 0.0;

          items.add(
            PurchaseReturnItem(
              id: UniqueKey().toString(),
              product: i['product'],
              barcode: i['barcode']?.toString() ?? '',
              itemName: i['itemName']?.toString() ?? 'Item',
              purchasedQty: pQty,
              alreadyReturnedQty: aRet,
              returnQty: returnable > 0 ? returnable : 0.0,
              unit: i['unit']?.toString() ?? 'piece',
              purchasePrice: (i['purchasePrice'] as num?)?.toDouble() ?? 0.0,
              discountAmount: unitDisc,
              taxPercent: (i['taxPercent'] as num?)?.toDouble() ?? 0.0,
              taxAmount: (i['taxAmount'] as num?)?.toDouble() ?? 0.0,
              returnAmount: (i['returnAmount'] as num?)?.toDouble() ?? 0.0,
              reason: 'Other',
            ),
          );
        }
      }
      formItems.assignAll(items);
    } catch (_) {
      formItems.clear();
    } finally {
      isFetchingItems.value = false;
    }
  }

  void updateItemReturnQty(int index, double qty) {
    if (index >= 0 && index < formItems.length) {
      final current = formItems[index];
      final maxRet = current.purchasedQty - current.alreadyReturnedQty;
      final safeQty = qty.clamp(0.0, maxRet);

      formItems[index] = PurchaseReturnItem(
        id: current.id,
        product: current.product,
        barcode: current.barcode,
        itemName: current.itemName,
        purchasedQty: current.purchasedQty,
        alreadyReturnedQty: current.alreadyReturnedQty,
        returnQty: safeQty,
        unit: current.unit,
        purchasePrice: current.purchasePrice,
        discountAmount: current.discountAmount,
        taxPercent: current.taxPercent,
        taxAmount: current.taxAmount,
        returnAmount: current.returnAmount,
        reason: current.reason,
      );
    }
  }

  void updateItemReason(int index, String reason) {
    if (index >= 0 && index < formItems.length) {
      final current = formItems[index];
      formItems[index] = PurchaseReturnItem(
        id: current.id,
        product: current.product,
        barcode: current.barcode,
        itemName: current.itemName,
        purchasedQty: current.purchasedQty,
        alreadyReturnedQty: current.alreadyReturnedQty,
        returnQty: current.returnQty,
        unit: current.unit,
        purchasePrice: current.purchasePrice,
        discountAmount: current.discountAmount,
        taxPercent: current.taxPercent,
        taxAmount: current.taxAmount,
        returnAmount: current.returnAmount,
        reason: reason,
      );
    }
  }

  void resetForm() {
    selectedSupplier.value = null;
    selectedBill.value = null;
    supplierBills.clear();
    formItems.clear();
    returnDate.value = DateTime.now().toIso8601String().split('T')[0];
    stateOfSupply.value = '';
    refundType.value = 'keep_as_debit';
    paymentMode.value = 'Cash';
    referenceNo.value = '';
    notes.value = '';
    roundOff.value = false;
  }

  Future<bool> saveReturn() async {
    if (selectedSupplier.value == null) {
      showErrorSnackbar('Please select a Supplier.');
      return false;
    }
    if (selectedBill.value == null) {
      showErrorSnackbar('Please select an Original Purchase Bill.');
      return false;
    }

    final activeItems = formItems.where((x) => x.returnQty > 0).toList();
    if (activeItems.isEmpty) {
      showErrorSnackbar(
        'Please specify return quantity for at least one item.',
      );
      return false;
    }

    if (refundType.value == 'refund_received' &&
        paymentMode.value.toLowerCase() != 'cash' &&
        (cashBankAccountId.value == null || cashBankAccountId.value!.isEmpty)) {
      showErrorSnackbar('Please select a bank account for non-cash refund.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = PurchaseReturnPayload(
        supplierId: selectedSupplier.value!.id,
        supplierName: selectedSupplier.value!.name,
        supplierPhone: selectedSupplier.value!.phone,
        supplierGstNo: selectedSupplier.value!.gstNumber,
        address: selectedSupplier.value!.address,
        originalPurchaseId: selectedBill.value!.id,
        originalPurchaseNo: selectedBill.value!.purchaseNumber,
        billDate: selectedBill.value!.purchaseDate,
        returnDate: returnDate.value,
        stateOfSupply: stateOfSupply.value.trim(),
        items: activeItems,
        subtotal: formSubtotal,
        totalDiscount: formTotalDiscount,
        totalTax: formTotalTax,
        roundOff: formRoundOffValue,
        grandTotal: formFinalGrandTotal,
        refundType: refundType.value,
        paymentMode: refundType.value == 'refund_received'
            ? paymentMode.value
            : 'Credit',
        cashBankAccountId: cashBankAccountId.value,
        referenceNo: referenceNo.value.trim(),
        notes: notes.value.trim(),
      );

      await _repository.createReturn(payload);

      Get.snackbar(
        'Success',
        'Purchase Return & Debit Note registered successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      resetForm();
      viewMode.value = 'list';
      loadReturns();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException
            ? e.message
            : 'Failed to create Purchase Return / Debit Note.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> cancelReturn(String id) async {
    try {
      await _repository.cancelReturn(id);
      Get.snackbar(
        'Success',
        'Debit Note cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadReturns();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to cancel Debit Note.',
      );
    }
  }

  Future<void> loadReturnDetails(String id) async {
    try {
      isLoadingDetail.value = true;
      final data = await _repository.getReturnById(id);
      selectedReturn.value = data;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load Debit Note details.',
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadReturns();
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
