import '../../../../core/api/api_exceptions.dart';
import '../models/day_book.dart';
import '../models/financial_report.dart';
import '../models/gst_report_summary.dart';
import '../services/accounting_report_service.dart';

class AccountingReportRepository {
  final AccountingReportService _service;

  AccountingReportRepository(this._service);

  Future<DayBook> fetchDayBook({String? date, String? search}) async {
    try {
      return await _service.getDayBook(date: date, search: search);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Day Book.');
    }
  }

  Future<TrialBalanceReport> fetchTrialBalance({
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getTrialBalance(
        startDate: startDate,
        endDate: endDate,
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
}
