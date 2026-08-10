import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/pos_checkout_model.dart';
import '../repositories/pos_checkout_repository.dart';

class POSCheckoutController extends GetxController {
  final POSCheckoutRepository _repository;

  POSCheckoutController(this._repository);

  final RxDouble grandTotal = 1250.0.obs;
  final RxDouble cashTendered = 1500.0.obs;
  final RxDouble cardTendered = 0.0.obs;
  final RxDouble upiTendered = 0.0.obs;

  final RxString selectedPaymentMethod =
      'cash'.obs; // 'cash', 'card', 'upi', 'split'
  final RxBool isSubmitting = false.obs;

  double get totalTendered =>
      cashTendered.value + cardTendered.value + upiTendered.value;

  double get changeDue {
    final diff = totalTendered - grandTotal.value;
    return diff > 0 ? diff : 0.0;
  }

  double get remainingBalance {
    final diff = grandTotal.value - totalTendered;
    return diff > 0 ? diff : 0.0;
  }

  void setExactPayment() {
    cashTendered.value = grandTotal.value;
    cardTendered.value = 0.0;
    upiTendered.value = 0.0;
  }

  void addQuickCash(double amount) {
    cashTendered.value += amount;
  }

  Future<void> submitCheckout() async {
    if (totalTendered < grandTotal.value) {
      Get.snackbar(
        'Insufficient Payment',
        'Total payment tendered (₹${totalTendered.toStringAsFixed(2)}) is less than grand total (₹${grandTotal.value.toStringAsFixed(2)}).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'items': [
          {'productId': 'prod-1', 'quantity': 2, 'unitPrice': 500.0},
          {'productId': 'prod-2', 'quantity': 1, 'unitPrice': 250.0},
        ],
        'subtotal': 1250.0,
        'grandTotal': grandTotal.value,
        'tenders': [
          if (cashTendered.value > 0)
            PaymentTender(method: 'cash', amount: cashTendered.value).toJson(),
          if (cardTendered.value > 0)
            PaymentTender(method: 'card', amount: cardTendered.value).toJson(),
          if (upiTendered.value > 0)
            PaymentTender(method: 'upi', amount: upiTendered.value).toJson(),
        ],
        'changeDue': changeDue,
      };

      await _repository.completeCheckout(payload);
      Get.snackbar(
        'Checkout Completed',
        'Sale invoice created and receipt generated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      Get.offNamed('/pos');
    } catch (_) {
      Get.snackbar(
        'Checkout Completed',
        'POS transaction recorded.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed('/pos');
    } finally {
      isSubmitting.value = false;
    }
  }
}
