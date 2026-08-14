import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/day_book.dart';
import '../models/financial_report.dart';
import '../models/gst_report_summary.dart';

class AccountingReportService {
  final ApiClient _apiClient;

  AccountingReportService(this._apiClient);

  Future<DayBook> getDayBook({
    String? startDate,
    String? endDate,
    String? voucherTypeCode,
    String? ledgerId,
    String? search,
    String? date,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (voucherTypeCode != null &&
        voucherTypeCode.isNotEmpty &&
        voucherTypeCode != 'ALL') {
      queryParams['voucherTypeCode'] = voucherTypeCode;
    }
    if (ledgerId != null && ledgerId.isNotEmpty && ledgerId != 'ALL') {
      queryParams['ledgerId'] = ledgerId;
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get(
      ApiEndpoints.accountingDayBook,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return DayBook.fromJson(data as Map<String, dynamic>);
  }

  Future<TrialBalanceReport> getTrialBalance({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.accountingReportTrialBalance,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return TrialBalanceReport.fromJson(data as Map<String, dynamic>);
  }

  Future<ProfitLossReport> getProfitLoss({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.accountingReportProfitLoss,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return ProfitLossReport.fromJson(data as Map<String, dynamic>);
  }

  Future<BalanceSheetReport> getBalanceSheet({String? asOfDate}) async {
    final Map<String, dynamic> queryParams = {};
    if (asOfDate != null && asOfDate.isNotEmpty) {
      queryParams['asOfDate'] = asOfDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.accountingReportBalanceSheet,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return BalanceSheetReport.fromJson(data as Map<String, dynamic>);
  }

  Future<GstReportSummary> getGstSummary({
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    dynamic responseData;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.accountingGstSummary,
        queryParameters: queryParams,
      );
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(
          '/accounting/reports/gst-summary',
          queryParameters: queryParams,
        );
        responseData = response.data;
      } catch (_) {
        return GstReportSummary(
          outputCgst: 0,
          outputSgst: 0,
          outputIgst: 0,
          inputCgst: 0,
          inputSgst: 0,
          inputIgst: 0,
          netTaxPayable: 0,
        );
      }
    }

    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return GstReportSummary.fromJson(data as Map<String, dynamic>);
  }
}
