import 'purchase_return_item.dart';

class PurchaseReturn {
  final String id;
  final String debitNoteNo;
  final String returnNumber;
  final String purchaseId;
  final String purchaseNumber;
  final String billDate;
  final dynamic supplierId;
  final String supplierName;
  final String? supplierPhone;
  final String? supplierGstNo;
  final String? address;
  final String returnDate;
  final String? stateOfSupply;
  final List<PurchaseReturnItem> items;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double roundOff;
  final double grandTotal;
  final String
  refundType; // 'refund_received', 'keep_as_debit', 'adjust_future_purchase'
  final String refundMethod;
  final String paymentMode; // 'Cash', 'Bank', 'UPI', 'Card', 'Credit'
  final String? cashBankAccountId;
  final double refundReceivedAmount;
  final double debitBalance;
  final String? referenceNo;
  final String
  status; // 'draft', 'issued', 'partially_refunded', 'refunded', 'adjusted', 'cancelled'
  final String? notes;
  final String createdAt;

  PurchaseReturn({
    required this.id,
    required this.debitNoteNo,
    required this.returnNumber,
    required this.purchaseId,
    required this.purchaseNumber,
    required this.billDate,
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    this.supplierGstNo,
    this.address,
    required this.returnDate,
    this.stateOfSupply,
    required this.items,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.roundOff,
    required this.grandTotal,
    required this.refundType,
    required this.refundMethod,
    required this.paymentMode,
    this.cashBankAccountId,
    required this.refundReceivedAmount,
    required this.debitBalance,
    this.referenceNo,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory PurchaseReturn.fromJson(Map<String, dynamic> json) {
    dynamic purId;
    String purNo =
        json['purchaseNumber']?.toString() ??
        json['originalPurchaseNo']?.toString() ??
        '';

    if (json['purchase'] != null) {
      if (json['purchase'] is Map<String, dynamic>) {
        purId = json['purchase']['_id'] ?? json['purchase']['id'];
        purNo = json['purchase']['purchaseNumber']?.toString() ?? purNo;
      } else {
        purId = json['purchase'].toString();
      }
    } else if (json['originalPurchaseId'] != null) {
      purId = json['originalPurchaseId'].toString();
    }

    dynamic suppId;
    String suppName = json['supplierName']?.toString() ?? 'Supplier';

    if (json['supplier'] != null) {
      if (json['supplier'] is Map<String, dynamic>) {
        suppId = json['supplier']['_id'] ?? json['supplier']['id'];
        suppName = json['supplier']['name']?.toString() ?? suppName;
      } else {
        suppId = json['supplier'].toString();
      }
    } else if (json['supplierId'] != null) {
      suppId = json['supplierId'].toString();
    }

    List<PurchaseReturnItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      for (final item in json['items'] as List) {
        if (item is Map<String, dynamic>) {
          try {
            itemList.add(PurchaseReturnItem.fromJson(item));
          } catch (_) {}
        }
      }
    }

    return PurchaseReturn(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      debitNoteNo:
          json['debitNoteNo']?.toString() ??
          json['returnNumber']?.toString() ??
          '',
      returnNumber:
          json['returnNumber']?.toString() ??
          json['debitNoteNo']?.toString() ??
          '',
      purchaseId: purId?.toString() ?? '',
      purchaseNumber: purNo,
      billDate:
          json['billDate']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      supplierId: suppId,
      supplierName: suppName,
      supplierPhone: json['supplierPhone']?.toString(),
      supplierGstNo: json['supplierGstNo']?.toString(),
      address: json['address']?.toString(),
      returnDate:
          json['returnDate']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      stateOfSupply: json['stateOfSupply']?.toString(),
      items: itemList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      roundOff: (json['roundOff'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      refundType: json['refundType']?.toString() ?? 'keep_as_debit',
      refundMethod: json['refundMethod']?.toString() ?? 'Credit',
      paymentMode: json['paymentMode']?.toString() ?? 'Cash',
      cashBankAccountId: json['cashBankAccountId']?.toString(),
      refundReceivedAmount:
          (json['refundReceivedAmount'] as num?)?.toDouble() ?? 0.0,
      debitBalance: (json['debitBalance'] as num?)?.toDouble() ?? 0.0,
      referenceNo: json['referenceNo']?.toString(),
      status: json['status']?.toString() ?? 'issued',
      notes: json['notes']?.toString(),
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
