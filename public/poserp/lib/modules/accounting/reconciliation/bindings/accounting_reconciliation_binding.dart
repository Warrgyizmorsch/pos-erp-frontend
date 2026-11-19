import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/accounting_reconciliation_controller.dart';
import '../repositories/accounting_reconciliation_repository.dart';
import '../services/accounting_reconciliation_service.dart';

class AccountingReconciliationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingReconciliationService>(
      () => AccountingReconciliationService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingReconciliationRepository>(
      () => AccountingReconciliationRepository(
        Get.find<AccountingReconciliationService>(),
      ),
    );
    Get.lazyPut<AccountingReconciliationController>(
      () => AccountingReconciliationController(
        Get.find<AccountingReconciliationRepository>(),
      ),
    );
  }
}
