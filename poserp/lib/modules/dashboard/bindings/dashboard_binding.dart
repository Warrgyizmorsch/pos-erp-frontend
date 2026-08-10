import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../parties/customers/bindings/customer_binding.dart';
import '../../products/inventory/bindings/stock_binding.dart';
import '../../purchases/bindings/purchase_binding.dart';
import '../../sales/bindings/sale_binding.dart';
import '../controllers/dashboard_controller.dart';
import '../repositories/dashboard_repository.dart';
import '../services/dashboard_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(
      () => DashboardService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(Get.find<DashboardService>()),
      fenix: true,
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
      fenix: true,
    );

    // Dependencies for embedded IndexedStack bottom nav tabs
    SaleBinding().dependencies();
    PurchaseBinding().dependencies();
    StockBinding().dependencies();
    CustomerBinding().dependencies();
  }
}
