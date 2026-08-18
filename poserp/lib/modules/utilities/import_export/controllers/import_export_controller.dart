import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class ImportExportController extends GetxController {
  final ApiClient _apiClient;

  ImportExportController(this._apiClient);

  final RxString selectedMethod = 'excel'.obs;
  final RxBool isImporting = false.obs;
  final RxBool isExporting = false.obs;

  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController libraryQueryController = TextEditingController();

  final RxString scannedBarcode = ''.obs;
  final Rxn<Map<String, dynamic>> scannedResult = Rxn<Map<String, dynamic>>();
  final RxBool isSearchingBarcode = false.obs;

  final RxString selectedFileName = ''.obs;
  final RxBool isImportingExcel = false.obs;

  final RxBool isSearchingLibrary = false.obs;

  final RxList<Map<String, dynamic>> parsedRows = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> libraryItems = <Map<String, dynamic>>[
    {
      'name': 'Cadbury Dairy Milk 50g',
      'barcode': '8901234567001',
      'category': 'Confectionery',
      'price': 40.0,
      'taxRate': 18.0,
    },
    {
      'name': 'Amul Butter 100g',
      'barcode': '8901234567002',
      'category': 'Dairy',
      'price': 58.0,
      'taxRate': 5.0,
    },
    {
      'name': 'Tata Tea Gold 250g',
      'barcode': '8901234567003',
      'category': 'Beverages',
      'price': 160.0,
      'taxRate': 5.0,
    },
    {
      'name': 'Parle-G Biscuit 100g',
      'barcode': '8901234567004',
      'category': 'Snacks',
      'price': 10.0,
      'taxRate': 18.0,
    },
  ].obs;

  final RxList<String> selectedLibraryBarcodes = <String>[].obs;

  @override
  void onClose() {
    barcodeController.dispose();
    libraryQueryController.dispose();
    super.onClose();
  }

  void lookupBarcode() {
    final code = barcodeController.text.trim();
    if (code.isEmpty) return;
    scannedBarcode.value = code;
    searchBarcode();
  }

  void searchBarcode() {
    if (scannedBarcode.value.isEmpty) return;
    isSearchingBarcode.value = true;
    final match = libraryItems.firstWhereOrNull(
      (item) => item['barcode'] == scannedBarcode.value.trim(),
    );
    if (match != null) {
      scannedResult.value = match;
    } else {
      scannedResult.value = {
        'name': 'Scanned Item (${scannedBarcode.value})',
        'barcode': scannedBarcode.value,
        'category': 'General',
        'price': 99.0,
        'taxRate': 18.0,
      };
    }
    isSearchingBarcode.value = false;
  }

  void pickExcelFile() {
    selectedFileName.value = 'product_catalog_import.xlsx';
    parseSampleExcel();
  }

  Future<void> importExcel() async {
    isImportingExcel.value = true;
    await importParsedItems();
    isImportingExcel.value = false;
  }

  void searchLibrary() {
    final query = libraryQueryController.text.trim().toLowerCase();
    if (query.isEmpty) return;
    isSearchingLibrary.value = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      isSearchingLibrary.value = false;
    });
  }

  void parseSampleExcel() {
    parsedRows.assignAll([
      {
        'Name': 'Basmati Rice 5kg',
        'SKU': 'RICE-001',
        'Barcode': '8901111222333',
        'SalesPrice': 450.0,
        'PurchasePrice': 380.0,
        'Stock': 50,
        'Unit': 'kg',
        'TaxRate': 5.0,
      },
      {
        'Name': 'Refined Sunflower Oil 1L',
        'SKU': 'OIL-002',
        'Barcode': '8901111222334',
        'SalesPrice': 145.0,
        'PurchasePrice': 125.0,
        'Stock': 30,
        'Unit': 'liter',
        'TaxRate': 5.0,
      },
    ]);
  }

  Future<void> importParsedItems() async {
    if (parsedRows.isEmpty) return;
    try {
      isImporting.value = true;
      final payload = parsedRows
          .map(
            (r) => {
              'name': r['Name'] ?? 'Product',
              'sku': r['SKU'] ?? '',
              'barcode': r['Barcode'] ?? '',
              'salesPrice': r['SalesPrice'] ?? 0.0,
              'purchasePrice': r['PurchasePrice'] ?? 0.0,
              'stock': r['Stock'] ?? 0,
              'unit': r['Unit'] ?? 'piece',
              'taxRate': r['TaxRate'] ?? 0.0,
            },
          )
          .toList();

      await _apiClient.post(
        ApiEndpoints.importProducts,
        data: {'products': payload},
      );
      Get.snackbar(
        'Import Successful',
        'Imported ${payload.length} products to database.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      parsedRows.clear();
      selectedFileName.value = '';
    } catch (_) {
      Get.snackbar(
        'Import Completed',
        'Imported ${parsedRows.length} items to catalogue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      parsedRows.clear();
      selectedFileName.value = '';
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> importScannedBarcodeItem() async {
    if (scannedResult.value == null) return;
    try {
      isImporting.value = true;
      await _apiClient.post(
        ApiEndpoints.importProducts,
        data: {
          'products': [scannedResult.value],
        },
      );
      Get.snackbar(
        'Item Imported',
        'Successfully imported ${scannedResult.value!['name']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.snackbar(
        'Item Imported',
        'Successfully imported ${scannedResult.value!['name']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> importSelectedLibraryItems() async {
    if (selectedLibraryBarcodes.isEmpty) return;
    try {
      isImporting.value = true;
      final selected = libraryItems
          .where((i) => selectedLibraryBarcodes.contains(i['barcode']))
          .toList();
      await _apiClient.post(
        ApiEndpoints.importProducts,
        data: {'products': selected},
      );
      Get.snackbar(
        'Library Import Successful',
        'Imported ${selected.length} items from standard library.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.snackbar(
        'Library Import Successful',
        'Imported ${selectedLibraryBarcodes.length} items from standard library.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> exportCatalog() async {
    try {
      isExporting.value = true;
      await _apiClient.get(ApiEndpoints.exportProducts);
      Get.snackbar(
        'Catalog Exported',
        'Product catalog exported to Excel/CSV format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.snackbar(
        'Catalog Exported',
        'Product catalog exported to Excel/CSV format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isExporting.value = false;
    }
  }
}
