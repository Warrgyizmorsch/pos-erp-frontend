import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/cash_bank_controller.dart';
import '../repositories/cash_bank_repository.dart';
import '../services/cash_bank_service.dart';

class CashBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashBankService>(() => CashBankService(Get.find<ApiClient>()));
    Get.lazyPut<CashBankRepository>(
      () => CashBankRepository(Get.find<CashBankService>()),
    );
    Get.lazyPut<CashBankController>(
      () => CashBankController(Get.find<CashBankRepository>()),
    );
  }
}
