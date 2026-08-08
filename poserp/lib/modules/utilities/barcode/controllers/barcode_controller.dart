import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/barcode_config.dart';

class BarcodeController extends GetxController {
  final Rx<BarcodeConfig> config = BarcodeConfig(
    productName: 'Sample Premium Product',
    barcodeValue: '8901234567890',
    price: 499.00,
    businessName: 'POS ERP Enterprise',
    copies: 12,
    showPrice: true,
    showBusinessName: true,
    showProductName: true,
    labelSize: '50mm x 25mm',
  ).obs;

  final RxBool isPrinting = false.obs;

  void generateRandomBarcode() {
    final Random random = Random();
    final String newCode = List.generate(12, (_) => random.nextInt(10)).join();
    config.value = config.value.copyWith(barcodeValue: newCode);
  }

  void updateProductName(String value) {
    config.value = config.value.copyWith(productName: value);
  }

  void updateBarcodeValue(String value) {
    config.value = config.value.copyWith(barcodeValue: value);
  }

  void updatePrice(double value) {
    config.value = config.value.copyWith(price: value);
  }

  void updateBusinessName(String value) {
    config.value = config.value.copyWith(businessName: value);
  }

  void updateCopies(int value) {
    if (value > 0 && value <= 200) {
      config.value = config.value.copyWith(copies: value);
    }
  }

  void toggleShowPrice(bool value) {
    config.value = config.value.copyWith(showPrice: value);
  }

  void toggleShowBusinessName(bool value) {
    config.value = config.value.copyWith(showBusinessName: value);
  }

  void toggleShowProductName(bool value) {
    config.value = config.value.copyWith(showProductName: value);
  }

  void updateLabelSize(String value) {
    config.value = config.value.copyWith(labelSize: value);
  }

  Future<void> printLabels() async {
    try {
      isPrinting.value = true;
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Print Job Sent',
        'Sent ${config.value.copies} barcode label copies to printer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isPrinting.value = false;
    }
  }
}
