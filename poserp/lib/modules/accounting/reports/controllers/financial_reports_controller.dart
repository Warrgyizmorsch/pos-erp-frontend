import 'package:get/get.dart';
import '../models/financial_report.dart';
import '../models/gst_report_summary.dart';
import '../repositories/accounting_report_repository.dart';

class FinancialReportsController extends GetxController {
  final AccountingReportRepository _repository;

  FinancialReportsController(this._repository);

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = true.obs;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  final Rxn<TrialBalanceReport> trialBalance = Rxn<TrialBalanceReport>();
  final Rxn<ProfitLossReport> profitLoss = Rxn<ProfitLossReport>();
  final Rxn<BalanceSheetReport> balanceSheet = Rxn<BalanceSheetReport>();
  final Rxn<GstReportSummary> gstSummary = Rxn<GstReportSummary>();

  @override
  void onInit() {
    super.onInit();
    loadCurrentTabReport();

    ever(selectedTabIndex, (_) => loadCurrentTabReport());
    ever(startDate, (_) => loadCurrentTabReport());
    ever(endDate, (_) => loadCurrentTabReport());
  }

  Future<void> loadCurrentTabReport() async {
    try {
      isLoading.value = true;
      if (selectedTabIndex.value == 0) {
        final tb = await _repository.fetchTrialBalance(
          startDate: startDate.value,
          endDate: endDate.value,
        );
        trialBalance.value = tb;
      } else if (selectedTabIndex.value == 1) {
        final pl = await _repository.fetchProfitLoss(
          startDate: startDate.value,
          endDate: endDate.value,
        );
        profitLoss.value = pl;
      } else if (selectedTabIndex.value == 2) {
        final bs = await _repository.fetchBalanceSheet(asOfDate: endDate.value);
        balanceSheet.value = bs;
      } else if (selectedTabIndex.value == 3) {
        final gst = await _repository.fetchGstSummary(
          startDate: startDate.value,
          endDate: endDate.value,
        );
        gstSummary.value = gst;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
