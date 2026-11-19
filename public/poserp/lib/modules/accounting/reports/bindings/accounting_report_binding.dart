import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/day_book_controller.dart';
import '../controllers/financial_reports_controller.dart';
import '../repositories/accounting_report_repository.dart';
import '../services/accounting_report_service.dart';

class AccountingReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountingReportService>(
      () => AccountingReportService(Get.find<ApiClient>()),
    );
    Get.lazyPut<AccountingReportRepository>(
      () => AccountingReportRepository(Get.find<AccountingReportService>()),
    );

    Get.lazyPut<DayBookController>(
      () => DayBookController(Get.find<AccountingReportRepository>()),
    );
    Get.lazyPut<FinancialReportsController>(
      () => FinancialReportsController(Get.find<AccountingReportRepository>()),
    );
  }
}
