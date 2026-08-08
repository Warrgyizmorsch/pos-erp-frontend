import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/loan_controller.dart';
import '../repositories/loan_repository.dart';
import '../services/loan_service.dart';

class LoanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoanService>(() => LoanService(Get.find<ApiClient>()));
    Get.lazyPut<LoanRepository>(() => LoanRepository(Get.find<LoanService>()));
    Get.lazyPut<LoanController>(
      () => LoanController(Get.find<LoanRepository>()),
    );
  }
}
