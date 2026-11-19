import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../ledgers/repositories/ledger_repository.dart';
import '../../ledgers/services/ledger_service.dart';
import '../controllers/bank_import_controller.dart';
import '../controllers/bank_import_settings_controller.dart';
import '../controllers/bank_mapping_rules_controller.dart';
import '../repositories/bank_import_repository.dart';
import '../services/bank_import_service.dart';

class BankImportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LedgerService>(() => LedgerService(Get.find<ApiClient>()));
    Get.lazyPut<LedgerRepository>(
      () => LedgerRepository(Get.find<LedgerService>()),
    );
    Get.lazyPut<BankImportService>(
      () => BankImportService(Get.find<ApiClient>()),
    );
    Get.lazyPut<BankImportRepository>(
      () => BankImportRepository(Get.find<BankImportService>()),
    );
    Get.lazyPut<BankImportController>(
      () => BankImportController(Get.find<BankImportRepository>()),
    );
    Get.lazyPut<BankMappingRulesController>(
      () => BankMappingRulesController(
        Get.find<BankImportRepository>(),
        Get.find<LedgerRepository>(),
      ),
    );
    Get.lazyPut<BankImportSettingsController>(
      () => BankImportSettingsController(
        Get.find<BankImportRepository>(),
        Get.find<LedgerRepository>(),
      ),
    );
  }
}
