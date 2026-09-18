import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../models/sale.dart';
import '../repositories/sale_repository.dart';

class SaleController extends GetxController {
  final SaleRepository _repository;

  SaleController(this._repository);

  final RxList<Sale> sales = <Sale>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString paymentFilter = 'all'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final int itemsPerPage = 20;

  // Summary Metrics
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble amountPaid = 0.0.obs;
  final RxDouble balanceAmount = 0.0.obs;

  final Rxn<Sale> selectedSale = Rxn<Sale>();

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadSales();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadSales();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadSales() async {
    try {
      isLoading.value = true;
      final result = await _repository.getSales(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
        paymentMethod: paymentFilter.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      sales.assignAll(result.data);

      if (result.totals.totalAmount > 0 || result.totals.amountPaid > 0) {
        totalAmount.value = result.totals.totalAmount;
        amountPaid.value = result.totals.amountPaid;
        balanceAmount.value = result.totals.balanceAmount;
      } else {
        totalAmount.value = sales.fold(0.0, (sum, s) => sum + s.totalAmount);
        amountPaid.value = sales.fold(0.0, (sum, s) => sum + s.amountPaid);
        balanceAmount.value = sales.fold(0.0, (sum, s) => sum + s.balanceDue);
      }

      if (result.pagination != null) {
        totalPages.value = result.pagination!.pages;
        totalItems.value = result.pagination!.total;
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load sales invoices',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void setPaymentFilter(String filter) {
    paymentFilter.value = filter;
    currentPage.value = 1;
    loadSales();
  }

  void setDateRange(String start, String end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1;
    loadSales();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadSales();
    }
  }

  Future<Sale?> loadSaleDetails(String id) async {
    try {
      final sale = await _repository.getSaleById(id);
      selectedSale.value = sale;
      return sale;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load sale details',
      );
      return null;
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _repository.deleteSale(id);
      AppSnackbar.success('Sale invoice deleted successfully.');
      loadSales();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete sale invoice',
      );
    }
  }

  Future<Sale?> fetchSaleById(String id) => loadSaleDetails(id);

  Future<bool> repostAccounting(String id) async {
    try {
      isSubmitting.value = true;
      await _repository.repostAccounting(id);
      AppSnackbar.success('Accounting voucher posted successfully.');
      await loadSaleDetails(id);
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to repost accounting voucher',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<Sale?> createSaleInvoice(Map<String, dynamic> data) async {
    try {
      isSubmitting.value = true;
      final sale = await _repository.createSale(data);
      AppSnackbar.success('Invoice #${sale.invoiceNumber} created successfully.');
      await loadSales();
      return sale;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to create sale invoice',
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  void showErrorSnackbar(String message) {
    AppSnackbar.error(message);
  }
}
