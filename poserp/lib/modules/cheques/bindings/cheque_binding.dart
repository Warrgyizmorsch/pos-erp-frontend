import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/cheque_list_controller.dart';
import '../repositories/cheque_repository.dart';
import '../services/cheque_service.dart';

class ChequeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChequeService>(
      () => ChequeService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ChequeRepository>(
      () => ChequeRepository(Get.find<ChequeService>()),
      fenix: true,
    );
    Get.lazyPut<ChequeListController>(
      () => ChequeListController(Get.find<ChequeRepository>()),
      fenix: true,
    );
  }
}
