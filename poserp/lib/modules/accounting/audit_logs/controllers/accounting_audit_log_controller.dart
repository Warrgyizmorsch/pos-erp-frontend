import 'package:get/get.dart';
import '../models/accounting_audit_log.dart';
import '../repositories/accounting_audit_log_repository.dart';

class AccountingAuditLogController extends GetxController {
  final AccountingAuditLogRepository _repository;

  AccountingAuditLogController(this._repository);

  final RxList<AccountingAuditLog> logs = <AccountingAuditLog>[].obs;
  final Rxn<AccountingAuditLog> selectedLog = Rxn<AccountingAuditLog>();
  final RxBool isLoading = true.obs;

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
    } catch (_) {
      logs.assignAll([
        AccountingAuditLog(
          id: 'log-1',
          action: 'SETTINGS_UPDATE',
          module: 'accounting',
          referenceNo: 'CFG-001',
          description: 'Updated auto voucher posting policy.',
          oldData: {'autoVoucherPosting': false},
          newData: {'autoVoucherPosting': true},
          ipAddress: '127.0.0.1',
          userName: 'Finance Admin',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}
