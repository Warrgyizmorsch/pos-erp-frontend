import 'package:get/get.dart';
import '../models/activity_log.dart';
import '../repositories/activity_log_repository.dart';

class ActivityLogController extends GetxController {
  final ActivityLogRepository _repository;

  ActivityLogController(this._repository);

  final RxList<ActivityLog> logs = <ActivityLog>[].obs;
  final RxBool isLoading = true.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalRecords = 0.obs;

  final RxString searchUser = ''.obs;
  final RxString selectedModule = 'all'.obs;
  final RxString selectedAction = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  bool get hasActiveFilters =>
      searchUser.value.isNotEmpty ||
      selectedModule.value != 'all' ||
      selectedAction.value != 'all' ||
      startDate.value.isNotEmpty ||
      endDate.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadLogs();

    debounce(searchUser, (_) {
      currentPage.value = 1;
      loadLogs();
    }, time: const Duration(milliseconds: 500));

    ever(selectedModule, (_) {
      currentPage.value = 1;
      loadLogs();
    });

    ever(selectedAction, (_) {
      currentPage.value = 1;
      loadLogs();
    });

    ever(startDate, (_) {
      currentPage.value = 1;
      loadLogs();
    });

    ever(endDate, (_) {
      currentPage.value = 1;
      loadLogs();
    });

    ever(currentPage, (_) => loadLogs());
  }

  Future<void> loadLogs() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchActivityLogs(
        page: currentPage.value,
        limit: 15,
        user: searchUser.value,
        module: selectedModule.value,
        action: selectedAction.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      logs.assignAll(res.logs);
      totalPages.value = res.totalPages;
      totalRecords.value = res.totalRecords;
    } catch (_) {
      logs.clear();
      totalPages.value = 1;
      totalRecords.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    searchUser.value = '';
    selectedModule.value = 'all';
    selectedAction.value = 'all';
    startDate.value = '';
    endDate.value = '';
    currentPage.value = 1;
    loadLogs();
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }
}
