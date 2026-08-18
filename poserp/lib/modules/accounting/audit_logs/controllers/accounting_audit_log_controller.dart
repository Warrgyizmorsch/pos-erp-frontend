import 'package:get/get.dart';
import '../models/accounting_audit_log.dart';
import '../repositories/accounting_audit_log_repository.dart';

class AccountingAuditLogController extends GetxController {
  final AccountingAuditLogRepository _repository;

  AccountingAuditLogController(this._repository);

  final RxList<AccountingAuditLog> logs = <AccountingAuditLog>[].obs;
  final Rxn<AccountingAuditLog> selectedLog = Rxn<AccountingAuditLog>();
  final RxBool isLoading = true.obs;

  final RxString startDateFilter = ''.obs;
  final RxString endDateFilter = ''.obs;
  final RxString actionFilter = ''.obs;
  final RxString moduleFilter = ''.obs;
  final RxString userFilter = ''.obs;
  final RxString searchFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      isLoading.value = true;
      final filters = <String, dynamic>{};
      if (startDateFilter.value.isNotEmpty) {
        filters['startDate'] = startDateFilter.value;
      }
      if (endDateFilter.value.isNotEmpty) {
        filters['endDate'] = endDateFilter.value;
      }
      if (actionFilter.value.isNotEmpty) {
        filters['action'] = actionFilter.value;
      }
      if (moduleFilter.value.isNotEmpty) {
        filters['module'] = moduleFilter.value;
      }
      if (userFilter.value.isNotEmpty) {
        filters['user'] = userFilter.value;
      }
      if (searchFilter.value.isNotEmpty) {
        filters['search'] = searchFilter.value;
      }

      final res = await _repository.fetchLogs(filters);
      logs.assignAll(res);
    } catch (e) {
      Get.log('Failed to load accounting audit logs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetFilters() {
    startDateFilter.value = '';
    endDateFilter.value = '';
    actionFilter.value = '';
    moduleFilter.value = '';
    userFilter.value = '';
    searchFilter.value = '';
    loadLogs();
  }
}
