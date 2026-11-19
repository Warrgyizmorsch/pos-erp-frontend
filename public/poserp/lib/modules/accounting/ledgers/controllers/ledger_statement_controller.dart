import 'package:get/get.dart';
import '../models/ledger_statement.dart';
import '../repositories/ledger_repository.dart';

class LedgerSideLine {
  final String date;
  final String particulars;
  final double amount;
  final String? meta;
  final String kind; // 'opening', 'entry', 'closing'

  LedgerSideLine({
    required this.date,
    required this.particulars,
    required this.amount,
    this.meta,
    required this.kind,
  });
}

class LedgerStatementSides {
  final List<LedgerSideLine> debit;
  final List<LedgerSideLine> credit;
  final double debitTotal;
  final double creditTotal;

  LedgerStatementSides({
    required this.debit,
    required this.credit,
    required this.debitTotal,
    required this.creditTotal,
  });
}

class LedgerStatementController extends GetxController {
  final LedgerRepository _repository;

  LedgerStatementController(this._repository);

  final Rxn<LedgerStatement> statement = Rxn<LedgerStatement>();
  final RxBool isLoading = true.obs;

  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;
  final RxString voucherTypeCode = ''.obs;
  final RxString searchQuery = ''.obs;

  late String ledgerId;

  @override
  void onInit() {
    super.onInit();
    ledgerId = Get.parameters['id'] ?? Get.arguments?.toString() ?? '';
    if (ledgerId.isNotEmpty) {
      loadStatement();
    }

    debounce(
      searchQuery,
      (_) => loadStatement(),
      time: const Duration(milliseconds: 300),
    );
    ever(startDate, (_) => loadStatement());
    ever(endDate, (_) => loadStatement());
    ever(voucherTypeCode, (_) => loadStatement());
  }

  Future<void> loadStatement() async {
    if (ledgerId.isEmpty) return;
    try {
      isLoading.value = true;
      final st = await _repository.fetchLedgerStatement(
        ledgerId,
        startDate: startDate.value,
        endDate: endDate.value,
        voucherTypeCode: voucherTypeCode.value,
        search: searchQuery.value,
      );
      statement.value = st;
    } catch (_) {
      statement.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  LedgerStatementSides? get sides {
    final st = statement.value;
    if (st == null) return null;

    final debit = <LedgerSideLine>[];
    final credit = <LedgerSideLine>[];
    final openingDate = startDate.value.isNotEmpty
        ? startDate.value
        : (st.entries.isNotEmpty ? st.entries.first.date : '');

    if (st.ledger.openingBalance.abs() > 0.009) {
      final line = LedgerSideLine(
        date: openingDate,
        particulars: 'Opening Balance',
        amount: st.ledger.openingBalance,
        kind: 'opening',
      );
      if (st.ledger.openingBalanceType == 'CREDIT') {
        credit.add(line);
      } else {
        debit.add(line);
      }
    }

    for (final entry in st.entries) {
      final metaText = '${entry.voucherNo} · ${entry.voucherTypeCode}';
      final String particularsText =
          (entry.referenceNo != null && entry.referenceNo!.isNotEmpty)
          ? entry.referenceNo!
          : (entry.narration != null && entry.narration!.isNotEmpty)
          ? entry.narration!
          : entry.voucherTypeName;

      if (entry.debit.abs() > 0.009) {
        debit.add(
          LedgerSideLine(
            date: entry.date,
            particulars: particularsText,
            amount: entry.debit,
            meta: metaText,
            kind: 'entry',
          ),
        );
      }
      if (entry.credit.abs() > 0.009) {
        credit.add(
          LedgerSideLine(
            date: entry.date,
            particulars: particularsText,
            amount: entry.credit,
            meta: metaText,
            kind: 'entry',
          ),
        );
      }
    }

    if (st.totals.closingBalance.abs() > 0.009) {
      final closingDate = st.entries.isNotEmpty ? st.entries.last.date : '';
      final line = LedgerSideLine(
        date: closingDate,
        particulars: 'Closing Balance',
        amount: st.totals.closingBalance,
        kind: 'closing',
      );
      if (st.totals.closingBalanceType == 'DEBIT') {
        credit.add(line);
      } else {
        debit.add(line);
      }
    }

    final dTot = debit.fold(0.0, (sum, l) => sum + l.amount);
    final cTot = credit.fold(0.0, (sum, l) => sum + l.amount);

    return LedgerStatementSides(
      debit: debit,
      credit: credit,
      debitTotal: dTot,
      creditTotal: cTot,
    );
  }
}
