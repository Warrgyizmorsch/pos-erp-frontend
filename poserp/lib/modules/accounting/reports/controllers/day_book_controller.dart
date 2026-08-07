import 'package:get/get.dart';
import '../models/day_book.dart';
import '../repositories/accounting_report_repository.dart';

class DayBookController extends GetxController {
  final AccountingReportRepository _repository;

  DayBookController(this._repository);

  final Rxn<DayBook> dayBook = Rxn<DayBook>();
  final RxBool isLoading = true.obs;

  final RxString selectedDate = DateTime.now()
      .toIso8601String()
      .split('T')[0]
      .obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDayBook();

    debounce(
      searchQuery,
      (_) => loadDayBook(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedDate, (_) => loadDayBook());
  }

  Future<void> loadDayBook() async {
    try {
      isLoading.value = true;
      final db = await _repository.fetchDayBook(
        date: selectedDate.value,
        search: searchQuery.value,
      );
      dayBook.value = db;
    } catch (_) {
      dayBook.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
