import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/accounting_dashboard_controller.dart';
import '../repositories/accounting_dashboard_repository.dart';
import '../services/accounting_dashboard_service.dart';

class AccountingDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingDashboardService>(
      () => AccountingDashboardService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingDashboardRepository>(
      () =>
          AccountingDashboardRepository(Get.find<AccountingDashboardService>()),
    );
    Get.lazyPut<AccountingDashboardController>(
      () => AccountingDashboardController(
        Get.find<AccountingDashboardRepository>(),
      ),
    );
  }
}
