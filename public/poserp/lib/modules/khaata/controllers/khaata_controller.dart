import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../models/khaata_party.dart';
import '../repositories/khaata_repository.dart';

class KhaataController extends GetxController {
  final KhaataRepository _repository;

  KhaataController(this._repository);

  final RxList<KhaataParty> parties = <KhaataParty>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs; // 'all', 'due', 'settled'
  final RxString partyTypeFilter = 'all'.obs; // 'all', 'customer', 'supplier'

  double get totalReceivable => parties
      .where((p) => p.currentBalance > 0)
      .fold(0.0, (acc, p) => acc + p.currentBalance);

  double get totalPayable => parties
      .where((p) => p.currentBalance < 0)
      .fold(0.0, (acc, p) => acc + p.currentBalance.abs());

  double get netOutstanding => totalReceivable - totalPayable;

  List<KhaataParty> get filteredParties {
    return parties.where((p) {
      final q = searchQuery.value.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.phone.contains(q);

      final matchesStatus = statusFilter.value == 'all'
          ? true
          : statusFilter.value == 'due'
              ? p.currentBalance != 0
              : p.currentBalance == 0;

      final matchesType = partyTypeFilter.value == 'all'
          ? true
          : p.partyType.toLowerCase() == partyTypeFilter.value.toLowerCase();

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadBalances();
  }

  Future<void> loadBalances() async {
    try {
      isLoading.value = true;
      final list = await _repository.getBalances();
      parties.assignAll(list);
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load khaata balances',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendWhatsAppReminder(KhaataParty party) async {
    final isCustomer = party.partyType == 'customer';
    final text = isCustomer
        ? 'Namaskar ${party.name},\n\nAapka hamare store par ₹${party.currentBalance.toStringAsFixed(2)} ka udhaar baaki hai. Kripya jald se jald bhugtaan karein.\n\nDhanyawad!'
        : 'Namaskar ${party.name},\n\nHamein aapko ₹${party.currentBalance.abs().toStringAsFixed(2)} ka payment karna baaki hai. Hum ise jald hi clear karenge.\n\nDhanyawad!';

    try {
      await _repository.logReminder(party.id, text);
    } catch (_) {
      // Continue opening whatsapp even if server logging fails
    }

    final cleanPhone = party.phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';
    final url = Uri.parse('https://wa.me/$fullPhone?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      AppSnackbar.success(
        'Opened WhatsApp reminder for ${party.name}',
        title: 'WhatsApp Reminder',
      );
      loadBalances();
    } else {
      showErrorSnackbar('Could not launch WhatsApp for phone: ${party.phone}');
    }
  }

  Future<bool> recordTransaction({
    required String partyId,
    required double amount,
    required String type, // 'payment_in' | 'payment_out'
    required String partyType,
    String? notes,
  }) async {
    if (amount <= 0) {
      showErrorSnackbar('Please enter a valid amount greater than zero');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.addTransaction(
        partyId,
        amount: amount,
        type: type,
        partyType: partyType,
        notes: notes,
      );

      AppSnackbar.success(
        type == 'payment_in'
            ? 'Payment received and posted to ledger successfully.'
            : 'Payment made and posted to ledger successfully.',
      );

      await loadBalances();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to record transaction',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void showErrorSnackbar(String message) {
    AppSnackbar.error(message);
  }
}
