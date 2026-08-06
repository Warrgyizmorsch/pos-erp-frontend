import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/stock_controller.dart';
import '../repositories/stock_repository.dart';
import '../services/stock_service.dart';

class StockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockService>(() => StockService(Get.find<ApiClient>()));
    Get.lazyPut<StockRepository>(
      () => StockRepository(Get.find<StockService>()),
    );
    Get.lazyPut<StockController>(
      () => StockController(Get.find<StockRepository>()),
    );
  }
}
