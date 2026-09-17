import 'package:get/get.dart';
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

  Future<void> loadDashboard({bool showLoading = true}) async {
    try {
      if (showLoading && summary.value == null) {
        isLoading.value = true;
      }
      final data = await _repository.fetchSummary();
      summary.value = data;
    } catch (_) {
      // Preserve existing summary on network hiccup/error
    } finally {
      isLoading.value = false;
    }
  }

  void setBottomNavIndex(int index) {
    activeBottomNavIndex.value = index;
  }
}
