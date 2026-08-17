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
  final RxString asOnDate = DateTime.now().toIso8601String().split('T')[0].obs;
  final RxString tbSelectedGroup = 'ALL'.obs;

  final Rxn<TrialBalanceReport> trialBalance = Rxn<TrialBalanceReport>();
  final Rxn<ProfitLossReport> profitLoss = Rxn<ProfitLossReport>();
  final Rxn<BalanceSheetReport> balanceSheet = Rxn<BalanceSheetReport>();
  final Rxn<GstReportSummary> gstSummary = Rxn<GstReportSummary>();
  final Rxn<AccountingReportDashboardModel> dashboardMetrics =
      Rxn<AccountingReportDashboardModel>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardMetrics();
    loadCurrentTabReport();

    ever(selectedTabIndex, (_) => loadCurrentTabReport());
    ever(startDate, (_) => loadCurrentTabReport());
    ever(endDate, (_) => loadCurrentTabReport());
    ever(asOnDate, (_) => loadCurrentTabReport());
  }

  Future<void> loadDashboardMetrics() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchReportDashboard();
      dashboardMetrics.value = res;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCurrentTabReport() async {
    try {
      isLoading.value = true;
      if (selectedTabIndex.value == 0) {
        final tb = await _repository.fetchTrialBalance(
          startDate: startDate.value,
          endDate: endDate.value,
          asOnDate: asOnDate.value,
        );
        trialBalance.value = tb;
      } else if (selectedTabIndex.value == 1) {
        final pl = await _repository.fetchProfitLoss(
          startDate: startDate.value,
          endDate: endDate.value,
        );
        profitLoss.value = pl;
      } else if (selectedTabIndex.value == 2) {
        final bs = await _repository.fetchBalanceSheet(
          asOfDate: endDate.value.isNotEmpty ? endDate.value : asOnDate.value,
        );
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

  List<String> get tbAvailableGroups {
    final tb = trialBalance.value;
    if (tb == null || tb.rows.isEmpty) return [];
    final set = <String>{};
    for (final r in tb.rows) {
      if (r.groupName.isNotEmpty && r.groupName != '-') {
        set.add(r.groupName);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  List<TrialBalanceRow> get tbFilteredRows {
    final tb = trialBalance.value;
    if (tb == null || tb.rows.isEmpty) return [];
    if (tbSelectedGroup.value == 'ALL') return tb.rows;
    return tb.rows.where((r) => r.groupName == tbSelectedGroup.value).toList();
  }

  double get tbTotalDebit {
    double sum = 0.0;
    for (final r in tbFilteredRows) {
      sum += r.debitBalance;
    }
    return sum;
  }

  double get tbTotalCredit {
    double sum = 0.0;
    for (final r in tbFilteredRows) {
      sum += r.creditBalance;
    }
    return sum;
  }

  double get tbDifference => (tbTotalDebit - tbTotalCredit).abs();

  bool get tbIsBalanced => tbTotalDebit > 0.0 && tbDifference < 0.01;
}
