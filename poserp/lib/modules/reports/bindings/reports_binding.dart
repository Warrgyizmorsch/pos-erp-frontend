import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/reports_controller.dart';
import '../repositories/reports_repository.dart';
import '../services/reports_service.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportsService>(() => ReportsService(Get.find<ApiClient>()));
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepository(Get.find<ReportsService>()),
    );
    Get.lazyPut<ReportsController>(
      () => ReportsController(Get.find<ReportsRepository>()),
    );
  }
}
