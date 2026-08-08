import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/accounting_settings_controller.dart';
import '../repositories/accounting_settings_repository.dart';
import '../services/accounting_settings_service.dart';

class AccountingSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingSettingsService>(
      () => AccountingSettingsService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingSettingsRepository>(
      () => AccountingSettingsRepository(Get.find<AccountingSettingsService>()),
    );
    Get.lazyPut<AccountingSettingsController>(
      () => AccountingSettingsController(
        Get.find<AccountingSettingsRepository>(),
      ),
    );
  }
}
