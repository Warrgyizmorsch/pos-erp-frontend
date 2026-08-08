import '../../../../core/api/api_exceptions.dart';
import '../models/loan.dart';
import '../services/loan_service.dart';

class LoanRepository {
  final LoanService _service;

  LoanRepository(this._service);

  Future<List<Loan>> fetchLoans() async {
    try {
      return await _service.getLoans();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch loans accounts.');
    }
  }

  Future<Loan> createLoan(Map<String, dynamic> payload) async {
    try {
      return await _service.createLoan(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create loan account.');
    }
  }

  Future<Loan> updateLoan(String id, Map<String, dynamic> payload) async {
    try {
      return await _service.updateLoan(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update loan account.');
    }
  }

  Future<void> removeLoan(String id) async {
    try {
      await _service.deleteLoan(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete loan account.');
    }
  }
}
