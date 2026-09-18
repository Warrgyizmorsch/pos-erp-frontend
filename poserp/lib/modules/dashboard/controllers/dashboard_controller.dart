import 'package:get/get.dart';
import '../../sales/controllers/sale_controller.dart';
import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;

  DashboardController(this._repository);

  final Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  final RxBool isLoading = true.obs;
  final RxInt activeBottomNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final data = await _repository.fetchSummary();
      if (summary.value == null ||
          data.todaySales > 0 ||
          data.totalProducts > 0 ||
          data.cashBankBalance > 0) {
        summary.value = data;
      }
    } catch (_) {
      // Retain existing summary.value on failure
    } finally {
      isLoading.value = false;
    }
  }

  void setBottomNavIndex(int index) {
    activeBottomNavIndex.value = index;
    if (index == 1 && Get.isRegistered<SaleController>()) {
      Get.find<SaleController>().loadSales();
    }
  }
}
