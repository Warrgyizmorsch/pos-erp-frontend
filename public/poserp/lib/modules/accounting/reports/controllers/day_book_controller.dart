import 'package:get/get.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../../ledgers/repositories/ledger_repository.dart';
import '../../vouchers/models/voucher_type.dart';
import '../../vouchers/repositories/voucher_repository.dart';
import '../models/day_book.dart';
import '../repositories/accounting_report_repository.dart';

class DayBookDateGroup {
  final String date;
  final List<DayBookEntry> entries;
  final double subtotalDebit;
  final double subtotalCredit;

  DayBookDateGroup({
    required this.date,
    required this.entries,
    required this.subtotalDebit,
    required this.subtotalCredit,
  });
}

class DayBookController extends GetxController {
  final AccountingReportRepository _repository;

  DayBookController(this._repository);

  final Rxn<DayBook> dayBook = Rxn<DayBook>();
  final RxBool isLoading = true.obs;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxString selectedVoucherType = 'ALL'.obs;
  final RxString selectedLedgerId = 'ALL'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<AccountingLedger> availableLedgers = <AccountingLedger>[].obs;
  final RxList<VoucherType> availableVoucherTypes = <VoucherType>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFilterOptions();
    loadDayBook();

    debounce(
      searchQuery,
      (_) => loadDayBook(),
      time: const Duration(milliseconds: 300),
    );
    ever(startDate, (_) => loadDayBook());
    ever(endDate, (_) => loadDayBook());
    ever(selectedVoucherType, (_) => loadDayBook());
    ever(selectedLedgerId, (_) => loadDayBook());
  }

  Future<void> loadFilterOptions() async {
    try {
      if (Get.isRegistered<LedgerRepository>()) {
        final ledgers = await Get.find<LedgerRepository>().fetchLedgers(
          status: 'ACTIVE',
        );
        availableLedgers.assignAll(ledgers);
      }
    } catch (_) {}

    try {
      if (Get.isRegistered<VoucherRepository>()) {
        final types = await Get.find<VoucherRepository>().fetchVoucherTypes();
        availableVoucherTypes.assignAll(types);
      }
    } catch (_) {}
  }

  Future<void> loadDayBook() async {
    try {
      isLoading.value = true;
      final db = await _repository.fetchDayBook(
        startDate: startDate.value,
        endDate: endDate.value,
        voucherTypeCode: selectedVoucherType.value,
        ledgerId: selectedLedgerId.value,
        search: searchQuery.value,
      );
      dayBook.value = db;
    } catch (_) {
      dayBook.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  List<DayBookDateGroup> get groupedEntries {
    final db = dayBook.value;
    if (db == null || db.entries.isEmpty) return [];

    final Map<String, List<DayBookEntry>> map = {};
    for (final e in db.entries) {
      final dateKey = e.date.contains('T') ? e.date.split('T')[0] : e.date;
      if (!map.containsKey(dateKey)) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(e);
    }

    return map.entries.map((entry) {
      double dTot = 0.0;
      double cTot = 0.0;
      for (final e in entry.value) {
        dTot += e.debit;
        cTot += e.credit;
      }
      return DayBookDateGroup(
        date: entry.key,
        entries: entry.value,
        subtotalDebit: dTot,
        subtotalCredit: cTot,
      );
    }).toList();
  }
}
