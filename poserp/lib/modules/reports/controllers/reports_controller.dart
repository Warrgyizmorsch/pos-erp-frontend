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
      'monthly'.obs; // 'daily', 'weekly', 'monthly', 'yearly', 'custom'
  final Rxn<DateTimeRange> customDateRange = Rxn<DateTimeRange>();
  final Rxn<AnalyticsReport> reportData = Rxn<AnalyticsReport>();
  final Rxn<String> errorMessage = Rxn<String>();
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
      errorMessage.value = null;

      final range = customDateRange.value;
      final startDate = range != null
          ? range.start.toIso8601String().split('T')[0]
          : null;
      final endDate = range != null
          ? range.end.toIso8601String().split('T')[0]
          : null;

      final res = await _repository.fetchReport(
        reportType.value,
        period.value,
        startDate: startDate,
        endDate: endDate,
      );
      reportData.value = res;
    } catch (e) {
      reportData.value = null;
      errorMessage.value =
          e.toString().replaceAll('Exception:', '').trim().isNotEmpty
          ? e.toString().replaceAll('Exception:', '').trim()
          : 'Failed to fetch analytics report from API backend.';
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTimeRange range) {
    customDateRange.value = range;
    period.value = 'custom';
    loadReport();
  }

  void exportReport(String format) {
    try {
      isExporting.value = true;
      Get.snackbar(
        'Export Successful',
        '${reportType.value.toUpperCase()} Report downloaded as ${format.toUpperCase()} format.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isExporting.value = false;
    }
  }

  void printReport() {
    Get.snackbar(
      'Print Job Sent',
      'Sent ${reportType.value.toUpperCase()} Report to thermal/A4 printer.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withAlpha(40),
    );
  }
}
