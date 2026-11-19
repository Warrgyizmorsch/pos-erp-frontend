import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/accounting_audit_log_controller.dart';
import '../repositories/accounting_audit_log_repository.dart';
import '../services/accounting_audit_log_service.dart';

class AccountingAuditLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingAuditLogService>(
      () => AccountingAuditLogService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingAuditLogRepository>(
      () => AccountingAuditLogRepository(Get.find<AccountingAuditLogService>()),
    );
    Get.lazyPut<AccountingAuditLogController>(
      () => AccountingAuditLogController(
        Get.find<AccountingAuditLogRepository>(),
      ),
    );
  }
}
