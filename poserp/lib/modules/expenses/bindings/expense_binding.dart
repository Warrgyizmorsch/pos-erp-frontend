import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/expense_controller.dart';
import '../repositories/expense_repository.dart';
import '../services/expense_service.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseService>(() => ExpenseService(Get.find<ApiClient>()));
    Get.lazyPut<ExpenseRepository>(
      () => ExpenseRepository(Get.find<ExpenseService>()),
    );
    Get.lazyPut<ExpenseController>(
      () => ExpenseController(Get.find<ExpenseRepository>()),
    );
  }
}
