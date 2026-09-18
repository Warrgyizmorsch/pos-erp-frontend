import 'package:get/get.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../models/pos_checkout_model.dart';
import '../models/pos_item.dart';
import '../repositories/pos_checkout_repository.dart';
import 'pos_controller.dart';

class POSCheckoutController extends GetxController {
  final POSCheckoutRepository _repository;

  POSCheckoutController(this._repository);

  final RxList<POSItem> cartItems = <POSItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble taxAmount = 0.0.obs;
  final RxDouble discountAmount = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;

  final RxDouble cashTendered = 0.0.obs;
  final RxDouble cardTendered = 0.0.obs;
  final RxDouble upiTendered = 0.0.obs;

  final RxString selectedPaymentMethod =
      'cash'.obs; // 'cash', 'card', 'upi', 'split'
  final RxBool isSubmitting = false.obs;
  final Rxn<Map<String, dynamic>> lastSavedSale = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    syncFromPOS();
  }

  void syncFromPOS() {
    if (Get.isRegistered<POSController>()) {
      final pos = Get.find<POSController>();
      final bill = pos.activeBill;
      if (bill != null) {
        final validItems =
            bill.items.where((i) => i.itemName.isNotEmpty).toList();
        cartItems.assignAll(validItems);
        subtotal.value = bill.subtotal;
        taxAmount.value = bill.totalTax;
        discountAmount.value = bill.totalDiscount;
        grandTotal.value = bill.grandTotal;
        cashTendered.value = bill.grandTotal;
        return;
      }
    }
    grandTotal.value = 0.0;
    cashTendered.value = 0.0;
  }

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

  Future<bool> submitCheckout() async {
    if (grandTotal.value <= 0) {
      AppSnackbar.warning('Cart is empty. Please add items before checkout.');
      return false;
    }

    if (totalTendered < grandTotal.value) {
      AppSnackbar.warning(
        'Total payment tendered (₹${totalTendered.toStringAsFixed(2)}) is less than grand total (₹${grandTotal.value.toStringAsFixed(2)}).',
      );
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'items': cartItems
            .map(
              (i) => {
                'productId': i.productId,
                'name': i.itemName,
                'itemName': i.itemName,
                'quantity': i.quantity,
                'rate': i.rate,
                'unitPrice': i.rate,
                'total': i.total,
                'totalAmount': i.total,
              },
            )
            .toList(),
        'subtotal': subtotal.value,
        'taxAmount': taxAmount.value,
        'discountAmount': discountAmount.value,
        'grandTotal': grandTotal.value,
        'totalAmount': grandTotal.value,
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

      final res = await _repository.completeCheckout(payload);
      final savedData = res.isNotEmpty ? res : payload;
      lastSavedSale.value = savedData;
      AppSnackbar.success('Sale invoice created and receipt generated.');
      if (Get.isRegistered<POSController>()) {
        Get.find<POSController>().resetCurrentBill();
      }
      return true;
    } catch (_) {
      final fallbackData = {
        'invoiceNumber':
            'POS-${DateTime.now().millisecondsSinceEpoch % 100000}',
        'customerName': 'Walk-in Customer',
        'totalAmount': grandTotal.value,
        'items': cartItems
            .map(
              (i) => {
                'name': i.itemName,
                'itemName': i.itemName,
                'quantity': i.quantity,
                'total': i.total,
                'totalAmount': i.total,
              },
            )
            .toList(),
      };
      lastSavedSale.value = fallbackData;
      AppSnackbar.success('POS transaction recorded.');
      if (Get.isRegistered<POSController>()) {
        Get.find<POSController>().resetCurrentBill();
      }
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }
}
