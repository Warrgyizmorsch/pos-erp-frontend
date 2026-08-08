import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/bank_import_controller.dart';
import '../controllers/bank_import_settings_controller.dart';
import '../controllers/bank_mapping_rules_controller.dart';
import '../repositories/bank_import_repository.dart';
import '../services/bank_import_service.dart';

class BankImportBinding extends Bindings {
  @override
  void dependencies() {
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
      () => BankMappingRulesController(Get.find<BankImportRepository>()),
    );
    Get.lazyPut<BankImportSettingsController>(
      () => BankImportSettingsController(Get.find<BankImportRepository>()),
    );
  }
}
