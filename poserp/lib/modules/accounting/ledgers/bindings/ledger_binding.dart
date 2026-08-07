import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/ledger_list_controller.dart';
import '../controllers/ledger_statement_controller.dart';
import '../repositories/ledger_repository.dart';
import '../services/ledger_service.dart';

class LedgerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerService>(() => LedgerService(Get.find<ApiClient>()));
    Get.lazyPut<LedgerRepository>(
      () => LedgerRepository(Get.find<LedgerService>()),
    );
    Get.lazyPut<LedgerListController>(
      () => LedgerListController(Get.find<LedgerRepository>()),
    );
    Get.lazyPut<LedgerStatementController>(
      () => LedgerStatementController(Get.find<LedgerRepository>()),
    );
  }
}
