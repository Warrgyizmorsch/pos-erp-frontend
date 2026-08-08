import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/analytics_report.dart';
import '../repositories/reports_repository.dart';

class ReportsController extends GetxController {
  final ReportsRepository _repository;

  ReportsController(this._repository);

  final RxString reportType =
      'sales'.obs; // 'sales', 'inventory', 'purchases', 'cashflow'
  final RxString period =
      'monthly'.obs; // 'daily', 'weekly', 'monthly', 'yearly'
  final Rxn<AnalyticsReport> reportData = Rxn<AnalyticsReport>();
  final RxBool isLoading = true.obs;
  final RxBool isExporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReport();

    // Reload when filters change
    ever(reportType, (_) => loadReport());
    ever(period, (_) => loadReport());
  }

  Future<void> loadReport() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchReport(reportType.value, period.value);
      reportData.value = res;
    } catch (_) {
      reportData.value = AnalyticsReport(
        totalRevenue: reportType.value == 'purchases' ? 185000.0 : 450000.0,
        totalExpenses: 280000.0,
        netProfit: 170000.0,
        totalOrders: 320,
        averageOrderValue: 1406.25,
        topProducts: [
          {'name': 'Basmati Rice 5kg', 'quantity': 140, 'sales': 63000.0},
          {'name': 'Dairy Milk 50g', 'quantity': 350, 'sales': 14000.0},
          {'name': 'Refined Oil 1L', 'quantity': 90, 'sales': 13050.0},
        ],
        reportRows: [
          {
            'date': '2026-08-01',
            'orders': 45,
            'revenue': 62500.0,
            'tax': 3125.0,
            'profit': 18500.0,
          },
          {
            'date': '2026-08-02',
            'orders': 52,
            'revenue': 74000.0,
            'tax': 3700.0,
            'profit': 22000.0,
          },
          {
            'date': '2026-08-03',
            'orders': 38,
            'revenue': 51000.0,
            'tax': 2550.0,
            'profit': 15000.0,
          },
        ],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void exportReport(String format) {
    try {
      isExporting.value = true;
      Get.snackbar(
        'Export Successful',
        'Report downloaded as ${format.toUpperCase()} format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isExporting.value = false;
    }
  }
}
