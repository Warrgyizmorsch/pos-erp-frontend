import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/dashboard_controller.dart';
import '../repositories/dashboard_repository.dart';
import '../services/dashboard_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardService>(
      () => DashboardService(Get.find<ApiClient>()),
    );
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(Get.find<DashboardService>()),
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
    );
  }
}
