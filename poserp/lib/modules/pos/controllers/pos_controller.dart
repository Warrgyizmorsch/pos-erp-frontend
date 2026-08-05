import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../parties/customers/models/customer.dart';
import '../../products/models/product.dart';
import '../models/pos_bill.dart';
import '../models/pos_item.dart';
import '../models/pos_sale_payload.dart';
import '../repositories/pos_repository.dart';

class POSController extends GetxController {
  final POSRepository _repository;

  POSController(this._repository);

  // State
  final RxList<POSBill> bills = <POSBill>[].obs;
  final RxString activeBillId = ''.obs;
  final RxInt nextBillNo = 2.obs;

  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<Customer> availableCustomers = <Customer>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isAmountEdited = false.obs;

  // Print modal data state
  final Rxn<Map<String, dynamic>> lastSavedSale = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _initInitialBill();
    loadInitialData();
  }

  void _initInitialBill() {
    const id = '1';
    final initialBill = POSBill(
      id: id,
      billNo: 1,
      customer: walkInCustomer,
      items: [_createPlaceholderItem()],
    );
    bills.assignAll([initialBill]);
    activeBillId.value = id;
  }

  POSItem _createPlaceholderItem() {
    return POSItem(
      id: Random().nextInt(9999999).toString(),
      itemType: 'inventory',
      affectsInventory: true,
      itemCode: '',
      itemName: '',
      customItem: true,
      quantity: 1,
      unit: 'Pcs',
      pricePerUnit: 0,
      rate: 0,
      purchasePrice: 0,
      taxPercent: 0,
      taxableAmount: 0,
      taxAmount: 0,
      total: 0,
      discount: 0,
      isInclusive: false,
    );
  }

  POSBill? get activeBill {
    return bills.firstWhereOrNull((b) => b.id == activeBillId.value);
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      final prods = await _repository.fetchProducts();
      final custs = await _repository.fetchCustomers();
      final banks = await _repository.fetchBankAccounts();

      availableProducts.assignAll(prods);
      availableCustomers.assignAll(custs);
      bankAccounts.assignAll(banks);
    } catch (e) {
      // Non-blocking log
    } finally {
      isLoading.value = false;
    }
  }

  void createNewBill() {
    final id = Random().nextInt(9999999).toString();
    final newBill = POSBill(
      id: id,
      billNo: nextBillNo.value,
      customer: walkInCustomer,
      items: [_createPlaceholderItem()],
    );
    bills.add(newBill);
    activeBillId.value = id;
    nextBillNo.value += 1;
    isAmountEdited.value = false;
  }

  void closeBill(String id) {
    if (bills.length == 1) {
      _initInitialBill();
      isAmountEdited.value = false;
      return;
    }
    bills.removeWhere((b) => b.id == id);
    if (activeBillId.value == id) {
      activeBillId.value = bills.first.id;
      isAmountEdited.value = false;
    }
  }

  void setActiveBill(String id) {
    activeBillId.value = id;
    isAmountEdited.value = false;
  }

  void setCustomer(Customer? customer) {
    final cur = activeBill;
    if (cur == null) return;
    _updateBill(cur.copyWith(customer: customer ?? walkInCustomer));
  }

  void setPaymentMode(String mode) {
    final cur = activeBill;
    if (cur == null) return;
    _updateBill(cur.copyWith(paymentMode: mode));
  }

  void setCashBankAccountId(String? accountId) {
    final cur = activeBill;
    if (cur == null) return;
    _updateBill(cur.copyWith(cashBankAccountId: accountId));
  }

  void setAmountReceived(double amount) {
    final cur = activeBill;
    if (cur == null) return;
    isAmountEdited.value = true;
    _updateBill(cur.copyWith(amountReceived: amount));
  }

  void addItemFromProduct(Product product) {
    final cur = activeBill;
    if (cur == null) return;

    final existingIdx = cur.items.indexWhere(
      (i) => i.itemType == 'inventory' && i.productId == product.id,
    );

    List<POSItem> updatedItems = List.from(cur.items);

    if (existingIdx >= 0) {
      final existing = updatedItems[existingIdx];
      final updated = POSItem.calculateAmounts(
        existing.copyWith(quantity: existing.quantity + 1),
      );
      updatedItems[existingIdx] = updated;
    } else {
      final newItem = POSItem.calculateAmounts(
        POSItem(
          id: Random().nextInt(9999999).toString(),
          productId: product.id,
          product: product,
          itemType: 'inventory',
          affectsInventory: true,
          itemCode: product.sku.isNotEmpty
              ? product.sku
              : (product.barcode ?? ''),
          itemName: product.name,
          customItem: false,
          quantity: 1,
          unit: product.unit,
          pricePerUnit: product.salesPrice,
          rate: product.salesPrice,
          purchasePrice: product.purchasePrice,
          taxPercent: product.taxRate,
          isInclusive: product.salesTaxType == 'with',
        ),
      );

      // Insert before last placeholder or append
      if (updatedItems.isNotEmpty && updatedItems.last.itemName.isEmpty) {
        updatedItems.insert(updatedItems.length - 1, newItem);
      } else {
        updatedItems.add(newItem);
        updatedItems.add(_createPlaceholderItem());
      }
    }

    _updateBillWithCalculatedTotals(cur.copyWith(items: updatedItems));
  }

  void updateItemQuantity(String itemId, double qty) {
    final cur = activeBill;
    if (cur == null) return;

    final updatedItems = cur.items.map((item) {
      if (item.id != itemId) return item;
      return POSItem.calculateAmounts(item.copyWith(quantity: qty));
    }).toList();

    _updateBillWithCalculatedTotals(cur.copyWith(items: updatedItems));
  }

  void updateItemPrice(String itemId, double price) {
    final cur = activeBill;
    if (cur == null) return;

    final updatedItems = cur.items.map((item) {
      if (item.id != itemId) return item;
      return POSItem.calculateAmounts(
        item.copyWith(pricePerUnit: price, rate: price),
      );
    }).toList();

    _updateBillWithCalculatedTotals(cur.copyWith(items: updatedItems));
  }

  void updateItemDiscount(String itemId, double disc) {
    final cur = activeBill;
    if (cur == null) return;

    final updatedItems = cur.items.map((item) {
      if (item.id != itemId) return item;
      return POSItem.calculateAmounts(item.copyWith(discount: disc));
    }).toList();

    _updateBillWithCalculatedTotals(cur.copyWith(items: updatedItems));
  }

  void removeItem(String itemId) {
    final cur = activeBill;
    if (cur == null) return;

    var updatedItems = cur.items.where((i) => i.id != itemId).toList();
    if (updatedItems.isEmpty ||
        updatedItems.every((i) => i.itemName.isNotEmpty)) {
      updatedItems.add(_createPlaceholderItem());
    }

    _updateBillWithCalculatedTotals(cur.copyWith(items: updatedItems));
  }

  void _updateBillWithCalculatedTotals(POSBill bill) {
    if (!isAmountEdited.value) {
      final newGrandTotal = bill.grandTotal;
      _updateBill(bill.copyWith(amountReceived: newGrandTotal));
    } else {
      _updateBill(bill);
    }
  }

  void _updateBill(POSBill bill) {
    final idx = bills.indexWhere((b) => b.id == bill.id);
    if (idx >= 0) {
      bills[idx] = bill;
    }
  }

  Future<bool> submitSale() async {
    final cur = activeBill;
    if (cur == null) return false;

    final validItems = cur.items.where((i) => i.itemName.isNotEmpty).toList();
    if (validItems.isEmpty) {
      showErrorSnackbar('Please add at least one product item to the cart.');
      return false;
    }

    final grandTotal = cur.grandTotal;
    final receivedAmount = min(cur.amountReceived, grandTotal);
    final paidInFull = receivedAmount >= grandTotal;

    final isWalkIn = cur.customer == null || cur.customer!.id == 'walk-in';
    final custId = isWalkIn ? null : cur.customer!.id;
    final custName = isWalkIn ? 'Walk-in Customer' : cur.customer!.name;

    final subtotal = validItems.fold(
      0.0,
      (sum, i) => sum + (i.quantity * i.pricePerUnit),
    );
    final taxAmt = validItems.fold(0.0, (sum, i) => sum + i.taxAmount);
    final discountAmt = validItems.fold(
      0.0,
      (sum, i) => sum + ((i.quantity * i.pricePerUnit) * (i.discount / 100.0)),
    );

    final String paymentMethod = cur.paymentMode == 'Partial'
        ? 'cash'
        : cur.paymentMode == 'Bank'
        ? 'upi'
        : cur.paymentMode.toLowerCase();

    final itemPayloads = validItems.map((i) {
      final base = i.quantity * i.pricePerUnit;
      final discAmt = base * (i.discount / 100.0);
      final taxable = i.isInclusive
          ? max(0.0, i.total - i.taxAmount)
          : max(0.0, base - discAmt);
      final cgst = double.parse((i.taxAmount / 2.0).toStringAsFixed(2));
      final sgst = double.parse((i.taxAmount - cgst).toStringAsFixed(2));

      final isInv = i.itemType == 'inventory';

      return POSSaleItemPayload(
        product: isInv ? i.productId : null,
        productId: isInv ? i.productId : null,
        itemType: i.itemType,
        affectsInventory: isInv,
        itemName: i.itemName,
        description: i.description ?? '',
        sku: i.itemCode,
        quantity: i.quantity,
        rate: i.pricePerUnit,
        unitPrice: i.pricePerUnit,
        purchasePrice: i.purchasePrice,
        discount: i.discount,
        taxRate: i.taxPercent,
        gstRate: i.taxPercent,
        taxableAmount: taxable,
        taxAmount: i.taxAmount,
        totalAmount: i.total,
        cgst: cgst,
        cgstAmount: cgst,
        sgst: sgst,
        sgstAmount: sgst,
        igst: 0,
        igstAmount: 0,
        hsn: isInv && i.product != null ? (i.product!.hsnCode ?? '') : '',
        total: i.total,
      );
    }).toList();

    final cgstTotal = itemPayloads.fold(0.0, (sum, i) => sum + i.cgst);
    final sgstTotal = itemPayloads.fold(0.0, (sum, i) => sum + i.sgst);

    final payload = POSSalePayload(
      customer: custId,
      customerName: custName,
      saleDate: DateTime.now().toIso8601String(),
      items: itemPayloads,
      subtotal: subtotal,
      taxAmount: taxAmt,
      totalCgst: cgstTotal,
      totalSgst: sgstTotal,
      totalIgst: 0,
      discountAmount: discountAmt,
      totalAmount: grandTotal,
      amountPaid: receivedAmount,
      status: 'completed',
      paymentStatus: paidInFull ? 'paid' : 'partial',
      paymentMethod: paymentMethod,
      notes: cur.remarks,
      cashBankAccountId: cur.cashBankAccountId,
    );

    try {
      isSubmitting.value = true;
      final savedData = await _repository.submitSale(
        payload,
        editingId: cur.editingId,
      );
      lastSavedSale.value = savedData;

      Get.snackbar(
        'Success',
        'Sale saved & receipt generated!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      // Reset bill
      resetCurrentBill();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to submit POS sale',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetCurrentBill() {
    final cur = activeBill;
    if (cur == null) return;
    isAmountEdited.value = false;
    _updateBill(
      POSBill(
        id: cur.id,
        billNo: cur.billNo,
        customer: walkInCustomer,
        items: [_createPlaceholderItem()],
      ),
    );
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
