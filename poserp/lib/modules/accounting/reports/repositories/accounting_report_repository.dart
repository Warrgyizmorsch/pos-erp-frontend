import '../../../../core/api/api_exceptions.dart';
import '../models/day_book.dart';
import '../models/financial_report.dart';
import '../models/gst_report_summary.dart';
import '../services/accounting_report_service.dart';

class AccountingReportRepository {
  final AccountingReportService _service;

  AccountingReportRepository(this._service);

  Future<DayBook> fetchDayBook({
    String? startDate,
    String? endDate,
    String? voucherTypeCode,
    String? ledgerId,
    String? search,
    String? date,
  }) async {
    try {
      return await _service.getDayBook(
        startDate: startDate,
        endDate: endDate,
        voucherTypeCode: voucherTypeCode,
        ledgerId: ledgerId,
        search: search,
        date: date,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Day Book.');
    }
  }

  Future<TrialBalanceReport> fetchTrialBalance({
    String? startDate,
    String? endDate,
    String? asOnDate,
  }) async {
    try {
      return await _service.getTrialBalance(
        startDate: startDate,
        endDate: endDate,
        asOnDate: asOnDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Trial Balance report.');
    }
  }

  Future<ProfitLossReport> fetchProfitLoss({
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getProfitLoss(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Profit & Loss report.');
    }
  }

  Future<BalanceSheetReport> fetchBalanceSheet({String? asOfDate}) async {
    try {
      return await _service.getBalanceSheet(asOfDate: asOfDate);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Balance Sheet report.');
    }
  }

  Future<BookReport> fetchCashBook({String? startDate, String? endDate}) async {
    try {
      return await _service.getCashBook(startDate: startDate, endDate: endDate);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Cash Book report.');
    }
  }

  Future<BookReport> fetchBankBook({String? startDate, String? endDate}) async {
    try {
      return await _service.getBankBook(startDate: startDate, endDate: endDate);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Bank Book report.');
    }
  }

  Future<GstReportSummary> fetchGstSummary({
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getGstSummary(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch GST Summary report.');
    }
  }

  Future<AccountingReportDashboardModel> fetchReportDashboard() async {
    try {
      return await _service.getReportDashboard();
    } catch (_) {
      return AccountingReportDashboardModel(
        totalIncome: 0,
        totalExpenses: 0,
        netProfit: 0,
        receivables: 0,
        payables: 0,
        cashBalance: 0,
        bankBalance: 0,
      );
    }
  }
}
