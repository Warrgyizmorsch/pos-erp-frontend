import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../ledgers/repositories/ledger_repository.dart';
import '../../ledgers/services/ledger_service.dart';
import '../controllers/journal_form_controller.dart';
import '../controllers/voucher_list_controller.dart';
import '../repositories/voucher_repository.dart';
import '../services/voucher_service.dart';

class VoucherBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoucherService>(
      () => VoucherService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<VoucherRepository>(
      () => VoucherRepository(Get.find<VoucherService>()),
      fenix: true,
    );

    Get.lazyPut<LedgerService>(
      () => LedgerService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<LedgerRepository>(
      () => LedgerRepository(Get.find<LedgerService>()),
      fenix: true,
    );

    Get.lazyPut<VoucherListController>(
      () => VoucherListController(Get.find<VoucherRepository>()),
      fenix: true,
    );
    Get.lazyPut<JournalFormController>(
      () => JournalFormController(
        Get.find<VoucherRepository>(),
        Get.find<LedgerRepository>(),
      ),
      fenix: true,
    );
  }
}
