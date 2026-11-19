import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/accounting_health_controller.dart';
import '../repositories/accounting_health_repository.dart';
import '../services/accounting_health_service.dart';

class AccountingHealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingHealthService>(
      () => AccountingHealthService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingHealthRepository>(
      () => AccountingHealthRepository(Get.find<AccountingHealthService>()),
    );
    Get.lazyPut<AccountingHealthController>(
      () => AccountingHealthController(Get.find<AccountingHealthRepository>()),
    );
  }
}
