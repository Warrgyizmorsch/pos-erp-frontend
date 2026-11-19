import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/sale_return.dart';
import '../models/sale_return_payload.dart';
import '../repositories/sale_return_repository.dart';

class SaleReturnFormItem {
  final String id;
  final String? product;
  final String? saleItemId;
  final String itemType;
  final bool affectsInventory;
  final String barcode;
  final String itemName;
  final double soldQty;
  final double alreadyReturnedQty;
  double returnQty;
  final String unit;
  final double pricePerUnit;
  final double discountAmount;
  final double taxPercent;
  String reason;
  String stockAction;

  SaleReturnFormItem({
    required this.id,
    this.product,
    this.saleItemId,
    required this.itemType,
    required this.affectsInventory,
    required this.barcode,
    required this.itemName,
    required this.soldQty,
    required this.alreadyReturnedQty,
    required this.returnQty,
    required this.unit,
    required this.pricePerUnit,
    required this.discountAmount,
    required this.taxPercent,
    this.reason = 'Other',
    this.stockAction = 'restore_stock',
  });

  double get maxReturn =>
      (soldQty - alreadyReturnedQty).clamp(0.0, double.infinity);
  double get lineBase => returnQty * pricePerUnit;
  double get lineDiscount => discountAmount * returnQty;
  double get lineTaxable => lineBase - lineDiscount;
  double get lineTax => (lineTaxable * taxPercent) / 100.0;
  double get lineTotal => lineTaxable + lineTax;
}

class SaleReturnController extends GetxController {
  final SaleReturnRepository _repository;

  SaleReturnController(this._repository);

  final RxList<SaleReturn> returns = <SaleReturn>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  // Filter States
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString refundFilter = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 15;

  // Form Masters & States
  final RxList<Customer> availableCustomers = <Customer>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;
  final RxList<Sale> customerInvoices = <Sale>[].obs;
  final RxList<SaleReturnFormItem> formItems = <SaleReturnFormItem>[].obs;
  final RxBool isFetchingInvoices = false.obs;
  final RxBool isFetchingItems = false.obs;

  final Rxn<Customer> selectedCustomer = Rxn<Customer>();
  final Rxn<Sale> selectedInvoice = Rxn<Sale>();
  final RxString returnDate = DateTime.now()
      .toIso8601String()
      .split('T')[0]
      .obs;
  final RxString stateOfSupply = ''.obs;
  final RxString refundType = 'refund_now'
      .obs; // 'refund_now', 'keep_as_credit', 'adjust_future_invoice'
  final RxString paymentMode = 'Cash'.obs;
  final RxnString selectedBankAccountId = RxnString();
  final RxString referenceNo = ''.obs;
  final RxString notes = ''.obs;
  final RxBool roundOff = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadReturns();
    loadFormDependencies();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadReturns();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadReturns() async {
    try {
      isLoading.value = true;
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
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load Credit Notes',
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
      if (banks.isNotEmpty) {
        selectedBankAccountId.value =
            banks.first['_id']?.toString() ?? banks.first['id']?.toString();
      }
    } catch (e) {
      // Non-blocking
    }
  }

  void onCustomerSelected(Customer? customer) async {
    selectedCustomer.value = customer;
    selectedInvoice.value = null;
    formItems.clear();
    customerInvoices.clear();

    if (customer == null) return;

    try {
      isFetchingInvoices.value = true;
      final invoices = await _repository.fetchUnreturnedSales(customer.id);
      customerInvoices.assignAll(invoices);
      if (invoices.isEmpty) {
        Get.snackbar(
          'Info',
          'No invoices with returnable items found for this customer.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      customerInvoices.clear();
    } finally {
      isFetchingInvoices.value = false;
    }
  }

  void onInvoiceSelected(Sale? invoice) async {
    selectedInvoice.value = invoice;
    formItems.clear();

    if (invoice == null) return;

    try {
      isFetchingItems.value = true;
      final res = await _repository.fetchReturnableItems(invoice.id);
      final saleData = res['sale'] as Map<String, dynamic>?;
      stateOfSupply.value = saleData?['stateOfSupply']?.toString() ?? '';

      final rawItems = res['items'] as List? ?? [];
      final List<SaleReturnFormItem> parsed = [];

      for (int i = 0; i < rawItems.length; i++) {
        final item = rawItems[i] as Map<String, dynamic>;
        final sold = (item['soldQty'] as num?)?.toDouble() ?? 0.0;
        final prevRet = (item['alreadyReturnedQty'] as num?)?.toDouble() ?? 0.0;
        final returnable =
            (item['returnableQty'] as num?)?.toDouble() ?? (sold - prevRet);
        final price = (item['pricePerUnit'] as num?)?.toDouble() ?? 0.0;
        final disc = (item['discountAmount'] as num?)?.toDouble() ?? 0.0;
        final unitDisc = sold > 0 ? disc / sold : 0.0;
        final affectsInv = item['affectsInventory'] as bool? ?? true;

        parsed.add(
          SaleReturnFormItem(
            id: 'item_$i',
            product: item['product']?.toString(),
            saleItemId: item['saleItemId']?.toString(),
            itemType:
                item['itemType']?.toString() ??
                (item['product'] != null ? 'inventory' : 'non_stock_product'),
            affectsInventory: affectsInv,
            barcode: item['barcode']?.toString() ?? '',
            itemName: item['itemName']?.toString() ?? 'Item',
            soldQty: sold,
            alreadyReturnedQty: prevRet,
            returnQty: returnable,
            unit: item['unit']?.toString() ?? 'Pcs',
            pricePerUnit: price,
            discountAmount: unitDisc,
            taxPercent: (item['taxPercent'] as num?)?.toDouble() ?? 0.0,
            reason: 'Other',
            stockAction: affectsInv
                ? (item['stockAction']?.toString() ?? 'restore_stock')
                : 'no_stock',
          ),
        );
      }

      formItems.assignAll(parsed);
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load invoice items',
      );
    } finally {
      isFetchingItems.value = false;
    }
  }

  void updateItemReturnQty(SaleReturnFormItem item, double qty) {
    item.returnQty = qty.clamp(0.0, item.maxReturn);
    formItems.refresh();
  }

  void updateItemReason(SaleReturnFormItem item, String reason) {
    item.reason = reason;
    formItems.refresh();
  }

  void updateItemStockAction(SaleReturnFormItem item, String action) {
    item.stockAction = action;
    formItems.refresh();
  }

  // Summary Metrics calculations for List View
  double get totalReturnedAmount => returns.fold(
    0.0,
    (s, x) => x.status != 'cancelled' ? s + x.grandTotal : s,
  );
  double get totalRefundedAmount => returns.fold(
    0.0,
    (s, x) => x.status != 'cancelled' ? s + x.refundedAmount : s,
  );
  double get totalCreditBalance => returns.fold(
    0.0,
    (s, x) => x.status != 'cancelled' ? s + x.creditBalance : s,
  );

  // Form Calculations
  double get formSubtotal => formItems.fold(0.0, (s, i) => s + i.lineBase);
  double get formTotalDiscount =>
      formItems.fold(0.0, (s, i) => s + i.lineDiscount);
  double get formTotalTax => formItems.fold(0.0, (s, i) => s + i.lineTax);
  double get formGrandTotal {
    final raw = formSubtotal - formTotalDiscount + formTotalTax;
    return roundOff.value ? raw.roundToDouble() : raw;
  }

  double get formRoundOffValue {
    final raw = formSubtotal - formTotalDiscount + formTotalTax;
    return formGrandTotal - raw;
  }

  Future<bool> submitCreditNote() async {
    if (selectedCustomer.value == null) {
      showErrorSnackbar('Please select a customer.');
      return false;
    }
    if (selectedInvoice.value == null) {
      showErrorSnackbar('Please select an original invoice.');
      return false;
    }

    final activeItems = formItems.where((x) => x.returnQty > 0).toList();
    if (activeItems.isEmpty) {
      showErrorSnackbar(
        'Please specify return quantity for at least one item.',
      );
      return false;
    }

    if (refundType.value == 'refund_now' &&
        paymentMode.value != 'Cash' &&
        (selectedBankAccountId.value == null ||
            selectedBankAccountId.value!.isEmpty)) {
      showErrorSnackbar('Please select a bank account for non-cash refund.');
      return false;
    }

    try {
      isSubmitting.value = true;

      final itemPayloads = activeItems
          .map(
            (i) => SaleReturnItemPayload(
              product: i.product,
              saleItemId: i.saleItemId,
              itemType: i.itemType,
              affectsInventory: i.affectsInventory,
              barcode: i.barcode,
              itemName: i.itemName,
              soldQty: i.soldQty,
              alreadyReturnedQty: i.alreadyReturnedQty,
              returnQty: i.returnQty,
              unit: i.unit,
              pricePerUnit: i.pricePerUnit,
              discountAmount: i.discountAmount * i.returnQty,
              taxPercent: i.taxPercent,
              reason: i.reason,
              stockAction: i.affectsInventory ? i.stockAction : 'no_stock',
            ),
          )
          .toList();

      final payload = SaleReturnPayload(
        customerId: selectedCustomer.value!.id,
        customerName: selectedCustomer.value!.name,
        customerPhone: selectedCustomer.value!.phone,
        customerGstNo: selectedCustomer.value!.gstNumber ?? '',
        billingAddress: selectedCustomer.value!.address ?? '',
        originalInvoiceId: selectedInvoice.value!.id,
        originalInvoiceNo: selectedInvoice.value!.invoiceNumber,
        invoiceDate: selectedInvoice.value!.createdAt,
        returnDate: returnDate.value,
        stateOfSupply: stateOfSupply.value,
        items: itemPayloads,
        subtotal: formSubtotal,
        totalDiscount: formTotalDiscount,
        totalTax: formTotalTax,
        roundOff: formRoundOffValue,
        grandTotal: formGrandTotal,
        refundType: refundType.value,
        paymentMode: refundType.value == 'refund_now'
            ? paymentMode.value
            : 'Credit',
        cashBankAccountId:
            refundType.value == 'refund_now' && paymentMode.value != 'Cash'
            ? selectedBankAccountId.value
            : null,
        referenceNo: referenceNo.value.trim(),
        notes: notes.value.trim(),
      );

      await _repository.createReturn(payload);
      Get.snackbar(
        'Success',
        'Sale Return & Credit Note issued successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // Reset form
      selectedCustomer.value = null;
      selectedInvoice.value = null;
      formItems.clear();
      notes.value = '';
      referenceNo.value = '';

      loadReturns();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to issue Credit Note',
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
        'Credit Note cancelled successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadReturns();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to cancel Credit Note',
      );
    }
  }

  void setStatusFilter(String filter) {
    statusFilter.value = filter;
    currentPage.value = 1;
    loadReturns();
  }

  void setRefundFilter(String filter) {
    refundFilter.value = filter;
    currentPage.value = 1;
    loadReturns();
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
