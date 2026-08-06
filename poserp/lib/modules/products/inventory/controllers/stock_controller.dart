import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/product.dart';
import '../models/stock_adjustment.dart';
import '../models/stock_movement.dart';
import '../repositories/stock_repository.dart';

class StockController extends GetxController {
  final StockRepository _repository;

  StockController(this._repository);

  final RxString activeTab =
      'current'.obs; // 'current', 'history', 'adjustments'

  // Current Stock State
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoadingCurrent = true.obs;
  final RxString searchQuery = ''.obs;

  // Stock Movement History State
  final RxList<StockMovement> movements = <StockMovement>[].obs;
  final RxBool isLoadingHistory = false.obs;
  final RxString historySearchQuery = ''.obs;
  final RxString selectedHistoryType = 'all'.obs;

  // Stock Adjustments State
  final RxList<StockAdjustment> adjustments = <StockAdjustment>[].obs;
  final RxBool isLoadingAdjustments = false.obs;
  final RxBool isSubmittingAdjustment = false.obs;

  // Dynamic Valuation
  double get totalInventoryValuation {
    return products.fold(0.0, (sum, p) => sum + (p.stock * p.purchasePrice));
  }

  @override
  void onInit() {
    super.onInit();
    loadCurrentStock();

    debounce(
      searchQuery,
      (_) => loadCurrentStock(),
      time: const Duration(milliseconds: 300),
    );
    debounce(
      historySearchQuery,
      (_) => loadMovements(),
      time: const Duration(milliseconds: 300),
    );

    ever(activeTab, (tab) {
      if (tab == 'history' && movements.isEmpty) {
        loadMovements();
      } else if (tab == 'adjustments' && adjustments.isEmpty) {
        loadAdjustments();
      }
    });

    ever(selectedHistoryType, (_) => loadMovements());
  }

  Future<void> loadCurrentStock() async {
    try {
      isLoadingCurrent.value = true;
      final res = await _repository.getCurrentStock(
        search: searchQuery.value,
        limit: 200,
      );
      products.assignAll(res.data);
    } catch (e) {
      products.clear();
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load inventory stock.',
      );
    } finally {
      isLoadingCurrent.value = false;
    }
  }

  Future<void> loadMovements() async {
    try {
      isLoadingHistory.value = true;
      final res = await _repository.getMovements(
        search: historySearchQuery.value,
        type: selectedHistoryType.value,
        limit: 200,
      );
      movements.assignAll(res.data);
    } catch (e) {
      movements.clear();
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load stock movements.',
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadAdjustments() async {
    try {
      isLoadingAdjustments.value = true;
      final res = await _repository.getAdjustments(limit: 200);
      adjustments.assignAll(res.data);
    } catch (e) {
      adjustments.clear();
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load stock adjustments.',
      );
    } finally {
      isLoadingAdjustments.value = false;
    }
  }

  Future<bool> createStockAdjustment({
    required String productId,
    required double adjustedStock,
    required String reason,
    String? notes,
  }) async {
    if (productId.isEmpty) {
      showErrorSnackbar('Please select a product.');
      return false;
    }
    if (reason.trim().isEmpty) {
      showErrorSnackbar('Please select or specify an adjustment reason.');
      return false;
    }

    try {
      isSubmittingAdjustment.value = true;
      await _repository.createAdjustment(
        productId: productId,
        adjustedStock: adjustedStock,
        reason: reason.trim(),
        notes: notes?.trim(),
      );

      Get.snackbar(
        'Success',
        'Stock adjustment recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      loadCurrentStock();
      if (activeTab.value == 'history') loadMovements();
      if (activeTab.value == 'adjustments') loadAdjustments();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to record stock adjustment.',
      );
      return false;
    } finally {
      isSubmittingAdjustment.value = false;
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
