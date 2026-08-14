class AccountingSettingsModel {
  final bool accountingEnabled;
  final bool autoVoucherPosting;
  final bool gstAccountingEnabled;
  final bool inventoryAccountingEnabled;
  final bool allowManualJournalEntry;
  final bool allowBackdatedVouchers;
  final String? lockBooksTillDate;
  final String? defaultCashLedgerId;
  final String? defaultBankLedgerId;
  final String? defaultSalesLedgerId;
  final String? defaultPurchaseLedgerId;
  final String? defaultSalesReturnLedgerId;
  final String? defaultPurchaseReturnLedgerId;
  final String? defaultRoundOffLedgerId;
  final String? defaultDiscountGivenLedgerId;
  final String? defaultDiscountReceivedLedgerId;
  final String? defaultStockLedgerId;
  final String? defaultCOGSLedgerId;

  AccountingSettingsModel({
    required this.accountingEnabled,
    required this.autoVoucherPosting,
    required this.gstAccountingEnabled,
    required this.inventoryAccountingEnabled,
    required this.allowManualJournalEntry,
    required this.allowBackdatedVouchers,
    this.lockBooksTillDate,
    this.defaultCashLedgerId,
    this.defaultBankLedgerId,
    this.defaultSalesLedgerId,
    this.defaultPurchaseLedgerId,
    this.defaultSalesReturnLedgerId,
    this.defaultPurchaseReturnLedgerId,
    this.defaultRoundOffLedgerId,
    this.defaultDiscountGivenLedgerId,
    this.defaultDiscountReceivedLedgerId,
    this.defaultStockLedgerId,
    this.defaultCOGSLedgerId,
  });

  factory AccountingSettingsModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      if (val is Map) return val['_id']?.toString() ?? val['id']?.toString();
      return null;
    }

    return AccountingSettingsModel(
      accountingEnabled: json['accountingEnabled'] == true,
      autoVoucherPosting: json['autoVoucherPosting'] == true,
      gstAccountingEnabled: json['gstAccountingEnabled'] == true,
      inventoryAccountingEnabled: json['inventoryAccountingEnabled'] == true,
      allowManualJournalEntry: json['allowManualJournalEntry'] == true,
      allowBackdatedVouchers: json['allowBackdatedVouchers'] == true,
      lockBooksTillDate: json['lockBooksTillDate']?.toString(),
      defaultCashLedgerId: extractId(json['defaultCashLedgerId']),
      defaultBankLedgerId: extractId(json['defaultBankLedgerId']),
      defaultSalesLedgerId: extractId(json['defaultSalesLedgerId']),
      defaultPurchaseLedgerId: extractId(json['defaultPurchaseLedgerId']),
      defaultSalesReturnLedgerId: extractId(json['defaultSalesReturnLedgerId']),
      defaultPurchaseReturnLedgerId: extractId(
        json['defaultPurchaseReturnLedgerId'],
      ),
      defaultRoundOffLedgerId: extractId(json['defaultRoundOffLedgerId']),
      defaultDiscountGivenLedgerId: extractId(
        json['defaultDiscountGivenLedgerId'],
      ),
      defaultDiscountReceivedLedgerId: extractId(
        json['defaultDiscountReceivedLedgerId'],
      ),
      defaultStockLedgerId: extractId(json['defaultStockLedgerId']),
      defaultCOGSLedgerId: extractId(json['defaultCOGSLedgerId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountingEnabled': accountingEnabled,
      'autoVoucherPosting': autoVoucherPosting,
      'gstAccountingEnabled': gstAccountingEnabled,
      'inventoryAccountingEnabled': inventoryAccountingEnabled,
      'allowManualJournalEntry': allowManualJournalEntry,
      'allowBackdatedVouchers': allowBackdatedVouchers,
      'lockBooksTillDate': lockBooksTillDate,
      'defaultCashLedgerId': defaultCashLedgerId,
      'defaultBankLedgerId': defaultBankLedgerId,
      'defaultSalesLedgerId': defaultSalesLedgerId,
      'defaultPurchaseLedgerId': defaultPurchaseLedgerId,
      'defaultSalesReturnLedgerId': defaultSalesReturnLedgerId,
      'defaultPurchaseReturnLedgerId': defaultPurchaseReturnLedgerId,
      'defaultRoundOffLedgerId': defaultRoundOffLedgerId,
      'defaultDiscountGivenLedgerId': defaultDiscountGivenLedgerId,
      'defaultDiscountReceivedLedgerId': defaultDiscountReceivedLedgerId,
      'defaultStockLedgerId': defaultStockLedgerId,
      'defaultCOGSLedgerId': defaultCOGSLedgerId,
    };
  }
}

class AccountingSettingsValidation {
  final bool valid;
  final List<String> warnings;
  final List<Map<String, dynamic>> missingLedgers;

  AccountingSettingsValidation({
    required this.valid,
    required this.warnings,
    required this.missingLedgers,
  });

  factory AccountingSettingsValidation.fromJson(Map<String, dynamic> json) {
    return AccountingSettingsValidation(
      valid: json['valid'] == true,
      warnings:
          (json['warnings'] as List?)?.map((e) => e.toString()).toList() ?? [],
      missingLedgers:
          (json['missingLedgers'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

class AccountingStatusModel {
  final bool initialized;
  final bool accountingEnabled;
  final int missingDefaultLedgersCount;
  final int missingDefaultGroupsCount;

  AccountingStatusModel({
    required this.initialized,
    required this.accountingEnabled,
    required this.missingDefaultLedgersCount,
    required this.missingDefaultGroupsCount,
  });

  factory AccountingStatusModel.fromJson(Map<String, dynamic> json) {
    return AccountingStatusModel(
      initialized: json['initialized'] == true,
      accountingEnabled: json['accountingEnabled'] == true,
      missingDefaultLedgersCount:
          (json['missingDefaultLedgersCount'] as num?)?.toInt() ?? 0,
      missingDefaultGroupsCount:
          (json['missingDefaultGroupsCount'] as num?)?.toInt() ?? 0,
    );
  }
}
