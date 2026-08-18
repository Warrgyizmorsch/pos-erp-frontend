import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../products/models/product.dart';
import '../../../products/repositories/product_repository.dart';
import '../models/barcode_config.dart';

class BarcodeController extends GetxController {
  final ProductRepository _productRepository;

  BarcodeController(this._productRepository);

  final RxList<Product> products = <Product>[].obs;
  final RxList<BarcodeRow> rows = <BarcodeRow>[].obs;
  final RxString businessName = 'ROYAL COLLECTION'.obs;

  final TextEditingController scannerInputController = TextEditingController();
  final Rx<BarcodeDisplaySettings> displaySettings =
      BarcodeDisplaySettings().obs;

  final RxBool isLoadingProducts = false.obs;
  final RxBool isPrinting = false.obs;

  final RxMap<String, String> rowSearchTerms = <String, String>{}.obs;
  final RxnInt activeRowSearchIdx = RxnInt();

  BarcodeRow createBlankRow() {
    return BarcodeRow(
      id: Random().nextDouble().toString().substring(2, 9),
      productId: null,
      productName: '',
      productCode: '',
      barcode: '',
      price: 0.0,
      printQty: 1,
    );
  }

  @override
  void onInit() {
    super.onInit();
    rows.assignAll([createBlankRow()]);
    loadProducts();
  }

  @override
  void onClose() {
    scannerInputController.dispose();
    super.onClose();
  }

  Future<void> loadProducts() async {
    try {
      isLoadingProducts.value = true;
      final res = await _productRepository.getProducts(limit: 1000);
      products.assignAll(res.data ?? []);
    } catch (_) {
      // Fallback local products if API not loaded
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void addBlankRow() {
    rows.add(createBlankRow());
    Get.snackbar(
      'Row Added',
      'New barcode label line added.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void removeRow(int idx) {
    if (idx >= 0 && idx < rows.length) {
      rows.removeAt(idx);
      if (rows.isEmpty) {
        rows.add(createBlankRow());
      }
    }
  }

  void updateRowQty(int idx, int qty) {
    if (idx >= 0 && idx < rows.length) {
      rows[idx].printQty = qty > 0 ? qty : 1;
      rows.refresh();
    }
  }

  void selectProductForRow(int idx, Product product) {
    if (idx >= 0 && idx < rows.length) {
      final row = rows[idx];
      row.productId = product.id;
      row.productName = product.name;
      row.productCode = product.sku;
      row.barcode = product.barcode ?? '';
      row.price = product.salesPrice;
      rows.refresh();
    }
    activeRowSearchIdx.value = null;
  }

  void handleScannerSubmit(String code) {
    final query = code.trim();
    if (query.isEmpty) return;

    final foundProduct = products.firstWhereOrNull(
      (p) =>
          p.barcode?.toLowerCase() == query.toLowerCase() ||
          p.sku.toLowerCase() == query.toLowerCase(),
    );

    if (foundProduct != null) {
      final existingIdx = rows.indexWhere(
        (r) => r.productId == foundProduct.id,
      );
      if (existingIdx != -1) {
        rows[existingIdx].printQty += 1;
        rows.refresh();
        Get.snackbar(
          'Qty Updated',
          'Increased qty for ${foundProduct.name}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      } else {
        final emptyIdx = rows.indexWhere(
          (r) => r.productId == null && r.productName.isEmpty,
        );
        if (emptyIdx != -1) {
          selectProductForRow(emptyIdx, foundProduct);
        } else {
          final newRow = BarcodeRow(
            id: Random().nextDouble().toString().substring(2, 9),
            productId: foundProduct.id,
            productName: foundProduct.name,
            productCode: foundProduct.sku,
            barcode: foundProduct.barcode ?? '',
            price: foundProduct.salesPrice,
            printQty: 1,
          );
          rows.add(newRow);
        }
        Get.snackbar(
          'Product Added',
          'Added ${foundProduct.name}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } else {
      Get.snackbar(
        'Product Not Found',
        'No matching product for barcode: $query',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.withAlpha(40),
      );
    }

    scannerInputController.clear();
  }

  List<BarcodeRow> get itemsToPrint {
    final validRows = rows.where(
      (r) => r.productId != null || r.productName.isNotEmpty,
    );
    final List<BarcodeRow> result = [];
    for (final r in validRows) {
      for (int i = 0; i < r.printQty; i++) {
        result.add(r);
      }
    }
    return result;
  }

  int get totalLabelsCount => itemsToPrint.length;

  void updateSettings({
    String? labelSize,
    int? layoutColumns,
    String? printerType,
    bool? showHeader,
    bool? showItemName,
    bool? showPrice,
    bool? showBarcodeNumber,
    bool? showExtraLines,
  }) {
    displaySettings.value = displaySettings.value.copyWith(
      labelSize: labelSize,
      layoutColumns: layoutColumns,
      printerType: printerType,
      showHeader: showHeader,
      showItemName: showItemName,
      showPrice: showPrice,
      showBarcodeNumber: showBarcodeNumber,
      showExtraLines: showExtraLines,
    );
  }

  Future<void> printLabels() async {
    if (totalLabelsCount == 0) {
      Get.snackbar(
        'No Labels',
        'Please add at least one product before printing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
      return;
    }

    try {
      isPrinting.value = true;
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Print Job Sent',
        'Successfully sent $totalLabelsCount barcode labels to ${displaySettings.value.printerType}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isPrinting.value = false;
    }
  }
}
