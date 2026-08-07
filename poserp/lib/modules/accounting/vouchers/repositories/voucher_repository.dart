import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_voucher.dart';
import '../models/voucher_type.dart';
import '../services/voucher_service.dart';

class VoucherRepository {
  final VoucherService _service;

  VoucherRepository(this._service);

  Future<List<VoucherType>> fetchVoucherTypes() async {
    try {
      return await _service.getVoucherTypes();
    } catch (_) {
      return [];
    }
  }

  Future<List<AccountingVoucher>> fetchVouchers({
    String? search,
    String? typeCode,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getVouchers(
        search: search,
        typeCode: typeCode,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch vouchers.');
    }
  }

  Future<AccountingVoucher> fetchVoucherById(String id) async {
    try {
      return await _service.getVoucherById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch voucher details.');
    }
  }

  Future<AccountingVoucher> saveJournalDraft(
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.createJournalDraft(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to save draft journal voucher.');
    }
  }

  Future<AccountingVoucher> postJournalVoucher(
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.postJournal(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to post journal voucher.');
    }
  }

  Future<void> postVoucher(String id) async {
    try {
      await _service.postVoucher(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to post voucher.');
    }
  }

  Future<void> cancelVoucher(String id, String reason) async {
    try {
      await _service.cancelVoucher(id, reason);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to cancel voucher.');
    }
  }
}
