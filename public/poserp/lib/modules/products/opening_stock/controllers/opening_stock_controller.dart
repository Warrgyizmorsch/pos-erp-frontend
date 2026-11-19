import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../models/opening_stock_entry.dart';
import '../models/opening_stock_payload.dart';
import '../repositories/opening_stock_repository.dart';

class OpeningStockController extends GetxController {
  final OpeningStockRepository _repository;
  final ProductRepository _productRepository;

  OpeningStockController(this._repository, this._productRepository);

  final RxList<OpeningStockItem> items = <OpeningStockItem>[].obs;
  final RxList<Product> availableProducts = <Product>[].obs;

  final RxString openingStockDate = DateTime.now()
      .toIso8601String()
      .split('T')[0]
      .obs;
  final RxString notes = ''.obs;
  final RxString globalTaxType = 'without'.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    addItem(); // Start with 1 row
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final res = await _productRepository.getProducts(limit: 500);
      availableProducts.value = res.data ?? [];
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void addItem() {
    final random = 1000 + Random().nextInt(9000);
    items.add(
      OpeningStockItem(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            random.toString(),
        sku: 'SKU-$random',
        purchaseTaxType: globalTaxType.value,
      ),
    );
  }

  void removeItem(int index) {
    if (items.length > 1) {
      items.removeAt(index);
    }
  }

  void setGlobalTaxType(String taxType) {
    globalTaxType.value = taxType;
    for (var item in items) {
      item.purchaseTaxType = taxType;
    }
    items.refresh();
  }

  void selectProduct(int index, Product product) {
    if (index >= 0 && index < items.length) {
      final item = items[index];
      item.product = product;
      item.productSearch = product.name;
      item.sku = product.sku;
      item.barcode = product.barcode ?? '';
      item.purchaseRate = product.purchasePrice;
      item.salesPrice = product.salesPrice;
      item.taxRate = product.taxRate;
      item.unit = product.unit;
      items.refresh();
    }
  }

  int get totalItems => items
      .where(
        (i) =>
            i.product != null ||
            i.productSearch.isNotEmpty ||
            (i.newProductName != null && i.newProductName!.isNotEmpty),
      )
      .length;

  double get totalQuantity => items.fold(0.0, (sum, i) => sum + i.quantity);

  double get totalValuation => items.fold(0.0, (sum, i) => sum + i.valuation);

  double get totalTax => items.fold(0.0, (sum, i) => sum + i.taxAmount);

  Future<bool> submit() async {
    final validItems = items
        .where(
          (i) =>
              i.product != null ||
              i.productSearch.trim().isNotEmpty ||
              (i.newProductName != null && i.newProductName!.trim().isNotEmpty),
        )
        .toList();

    if (validItems.isEmpty) {
      showErrorSnackbar('Please add at least one product row.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payloadItems = validItems.map((item) {
        final name =
            item.product?.name ??
            item.newProductName?.trim() ??
            item.productSearch.trim();
        return OpeningStockPayloadItem(
          product: item.product?.id,
          productId: item.product?.id,
          itemName: name,
          productName: name,
          name: name,
          sku: item.product?.sku ?? item.sku.trim(),
          barcode:
              item.product?.barcode ??
              (item.barcode.trim().isNotEmpty ? item.barcode.trim() : null),
          unit: item.unit,
          quantity: item.quantity,
          purchasePrice: item.basePurchaseRate,
          salesPrice: item.salesPrice,
          taxRate: item.taxRate,
          openingStockDate: openingStockDate.value,
          isNewProduct: item.product == null,
        );
      }).toList();

      final payload = OpeningStockPayload(
        openingStockDate: openingStockDate.value,
        notes: notes.value.trim().isNotEmpty ? notes.value.trim() : null,
        items: payloadItems,
      );

      await _repository.submitOpeningStock(payload);

      Get.snackbar(
        'Success',
        'Opening stock saved! Inventory updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } catch (e) {
      final msg = e is AppException
          ? e.message
          : 'Failed to save opening stock.';
      showErrorSnackbar(msg);
      return false;
    } finally {
      isSubmitting.value = false;
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
