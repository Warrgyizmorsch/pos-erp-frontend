import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../parties/suppliers/models/supplier.dart';
import '../../parties/transporters/models/transporter.dart';
import '../../products/models/product.dart';
import '../models/purchase.dart';
import '../models/purchase_payload.dart';
import '../repositories/purchase_repository.dart';

class PurchaseFormItemRow {
  final String id;
  Product? product;
  String name;
  String sku;
  String barcode;
  double quantity;
  double purchasePrice;
  double salesPrice;
  double taxRate;

  PurchaseFormItemRow({
    required this.id,
    this.product,
    required this.name,
    required this.sku,
    required this.barcode,
    this.quantity = 1,
    this.purchasePrice = 0,
    this.salesPrice = 0,
    this.taxRate = 0,
  });

  double get lineTaxable => quantity * purchasePrice;
  double get lineTax => (lineTaxable * taxRate) / 100.0;
  double get lineTotal => lineTaxable + lineTax;
}

class PurchaseController extends GetxController {
  final PurchaseRepository _repository;

  PurchaseController(this._repository);

  final RxList<Purchase> purchases = <Purchase>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  // Filter States
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString paymentFilter = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 20;

  // Selected Purchase for Detail View
  final Rxn<Purchase> selectedPurchase = Rxn<Purchase>();

  // Form Masters & States
  final RxList<Supplier> availableSuppliers = <Supplier>[].obs;
  final RxList<Transporter> availableTransporters = <Transporter>[].obs;
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;

  // Form Fields
  final Rxn<Supplier> formSupplier = Rxn<Supplier>();
  final Rxn<Transporter> formTransporter = Rxn<Transporter>();
  final RxString formInvoiceNumber = ''.obs;
  final RxString formPurchaseDate = DateTime.now()
      .toIso8601String()
      .split('T')[0]
      .obs;
  final RxString formStateOfSupply = 'Rajasthan'.obs;
  final RxDouble formShippingCharges = 0.0.obs;
  final RxDouble formDiscountAmount = 0.0.obs;
  final RxBool formRoundOff = false.obs;
  final RxString formPaymentMethod = 'cash'.obs;
  final RxnString formBankAccountId = RxnString();
  final RxDouble formAmountPaid = 0.0.obs;
  final RxString formStatus = 'confirmed'.obs;
  final RxString formNotes = 'Thanks for doing business with us!'.obs;
  final RxList<PurchaseFormItemRow> formItems = <PurchaseFormItemRow>[].obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadPurchases();
    loadFormDependencies();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadPurchases();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadPurchases() async {
    try {
      isLoading.value = true;
      final result = await _repository.getPurchases(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
        status: statusFilter.value,
        paymentStatus: paymentFilter.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      purchases.assignAll(result.data);
      if (result.pagination != null) {
        totalPages.value = result.pagination!.pages;
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load purchase bills',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFormDependencies() async {
    try {
      final supps = await _repository.fetchSuppliers();
      final trans = await _repository.fetchTransporters();
      final prods = await _repository.fetchProducts();
      final banks = await _repository.fetchBankAccounts();

      availableSuppliers.assignAll(supps);
      availableTransporters.assignAll(trans);
      availableProducts.assignAll(prods);
      bankAccounts.assignAll(banks);
    } catch (e) {
      // Non-blocking
    }
  }

  void initNewForm() {
    formSupplier.value = null;
    formTransporter.value = null;
    formInvoiceNumber.value = '';
    formPurchaseDate.value = DateTime.now().toIso8601String().split('T')[0];
    formStateOfSupply.value = 'Rajasthan';
    formShippingCharges.value = 0.0;
    formDiscountAmount.value = 0.0;
    formRoundOff.value = false;
    formPaymentMethod.value = 'cash';
    formBankAccountId.value = null;
    formAmountPaid.value = 0.0;
    formStatus.value = 'confirmed';
    formNotes.value = 'Thanks for doing business with us!';
    formItems.assignAll([
      PurchaseFormItemRow(id: 'item_0', name: '', sku: '', barcode: ''),
    ]);
  }

  void initEditForm(Purchase purchase) {
    if (purchase.supplier is Supplier) {
      formSupplier.value = purchase.supplier as Supplier;
    } else {
      formSupplier.value = availableSuppliers.firstWhereOrNull(
        (s) => s.id == purchase.supplier,
      );
    }
    if (purchase.transporter != null) {
      formTransporter.value = availableTransporters.firstWhereOrNull(
        (t) => t.id == purchase.transporter,
      );
    } else {
      formTransporter.value = null;
    }

    formInvoiceNumber.value = purchase.invoiceNumber ?? '';
    formPurchaseDate.value = purchase.purchaseDate.split('T')[0];
    formStateOfSupply.value = purchase.stateOfSupply ?? 'Rajasthan';
    formShippingCharges.value = purchase.shippingCharges;
    formDiscountAmount.value = purchase.discountAmount;
    formRoundOff.value = purchase.roundOff;
    formPaymentMethod.value = purchase.paymentMethod;
    formBankAccountId.value = purchase.cashBankAccountId;
    formAmountPaid.value = purchase.amountPaid;
    formStatus.value = purchase.status;
    formNotes.value = purchase.notes ?? '';

    final rows = purchase.items.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      Product? prod;
      if (item.product != null) {
        prod = availableProducts.firstWhereOrNull((p) => p.id == item.product);
      }
      return PurchaseFormItemRow(
        id: 'item_$idx',
        product: prod,
        name: item.name,
        sku: item.sku ?? '',
        barcode: item.barcode ?? '',
        quantity: item.quantity,
        purchasePrice: item.purchasePrice,
        salesPrice: item.salesPrice,
        taxRate: item.taxRate,
      );
    }).toList();

    formItems.assignAll(
      rows.isNotEmpty
          ? rows
          : [PurchaseFormItemRow(id: 'item_0', name: '', sku: '', barcode: '')],
    );
  }

  void addFormItemRow() {
    final idx = formItems.length;
    formItems.add(
      PurchaseFormItemRow(id: 'item_$idx', name: '', sku: '', barcode: ''),
    );
  }

  void removeFormItemRow(int idx) {
    if (formItems.length > 1) {
      formItems.removeAt(idx);
    }
  }

  void selectProductForItemRow(PurchaseFormItemRow item, Product product) {
    item.product = product;
    item.name = product.name;
    item.sku = product.sku;
    item.barcode = product.barcode ?? '';
    item.purchasePrice = product.purchasePrice;
    item.salesPrice = product.salesPrice;
    item.taxRate = product.taxRate;
    formItems.refresh();
  }

  double get formSubtotal => formItems.fold(0.0, (s, i) => s + i.lineTaxable);
  double get formTotalTax => formItems.fold(0.0, (s, i) => s + i.lineTax);
  double get formGrandTotal {
    final raw =
        formSubtotal -
        formDiscountAmount.value +
        formShippingCharges.value +
        formTotalTax;
    return formRoundOff.value ? raw.roundToDouble() : raw;
  }

  String calculatePaymentStatus(double total, double paid) {
    if (paid >= total && total > 0) return 'paid';
    if (paid > 0 && paid < total) return 'partial';
    return 'pending';
  }

  Future<bool> savePurchase({String? editId}) async {
    if (formSupplier.value == null) {
      showErrorSnackbar('Please select a supplier.');
      return false;
    }
    final validItems = formItems
        .where((i) => i.name.trim().isNotEmpty && i.quantity > 0)
        .toList();
    if (validItems.isEmpty) {
      showErrorSnackbar('Please add at least one valid purchase item.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final total = formGrandTotal;
      final paid = formAmountPaid.value;
      final pStatus = calculatePaymentStatus(total, paid);

      final itemPayloads = validItems
          .map(
            (i) => PurchaseItemPayload(
              product: i.product?.id,
              name: i.name,
              sku: i.sku,
              barcode: i.barcode,
              quantity: i.quantity,
              purchasePrice: i.purchasePrice,
              salesPrice: i.salesPrice,
              taxRate: i.taxRate,
              total: i.lineTotal,
            ),
          )
          .toList();

      final payload = PurchasePayload(
        supplier: formSupplier.value!.id,
        supplierName: formSupplier.value!.name,
        supplierPhone: formSupplier.value!.phone,
        supplierGst: formSupplier.value!.gstNumber,
        invoiceNumber: formInvoiceNumber.value.trim(),
        purchaseDate: formPurchaseDate.value,
        stateOfSupply: formStateOfSupply.value,
        transporter: formTransporter.value?.id,
        items: itemPayloads,
        subtotal: formSubtotal,
        discountAmount: formDiscountAmount.value,
        shippingCharges: formShippingCharges.value,
        taxAmount: formTotalTax,
        roundOff: formRoundOff.value,
        totalAmount: total,
        amountPaid: paid,
        status: formStatus.value,
        paymentStatus: pStatus,
        paymentMethod: formPaymentMethod.value,
        cashBankAccountId: formBankAccountId.value,
        notes: formNotes.value.trim(),
      );

      if (editId != null && editId.isNotEmpty) {
        await _repository.updatePurchase(editId, payload);
        Get.snackbar(
          'Success',
          'Purchase bill updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _repository.createPurchase(payload);
        Get.snackbar(
          'Success',
          'Purchase bill created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      loadPurchases();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to save purchase bill',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<Purchase?> loadPurchaseDetails(String id) async {
    try {
      isLoading.value = true;
      final purchase = await _repository.getPurchaseById(id);
      selectedPurchase.value = purchase;
      return purchase;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load purchase details',
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _repository.deletePurchase(id);
      Get.snackbar(
        'Success',
        'Purchase bill deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPurchases();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete purchase bill',
      );
    }
  }

  Future<void> repostAccounting(String id) async {
    try {
      isSubmitting.value = true;
      await _repository.repostAccounting(id);
      Get.snackbar(
        'Success',
        'Accounting voucher posted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadPurchaseDetails(id);
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to repost accounting voucher',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void setStatusFilter(String filter) {
    statusFilter.value = filter;
    currentPage.value = 1;
    loadPurchases();
  }

  void setPaymentFilter(String filter) {
    paymentFilter.value = filter;
    currentPage.value = 1;
    loadPurchases();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadPurchases();
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
