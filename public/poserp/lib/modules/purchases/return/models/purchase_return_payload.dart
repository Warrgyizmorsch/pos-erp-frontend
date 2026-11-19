import 'purchase_return_item.dart';

class PurchaseReturnPayload {
  final String supplierId;
  final String supplierName;
  final String? supplierPhone;
  final String? supplierGstNo;
  final String? address;
  final String originalPurchaseId;
  final String originalPurchaseNo;
  final String? billDate;
  final String returnDate;
  final String? stateOfSupply;
  final List<PurchaseReturnItem> items;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double roundOff;
  final double grandTotal;
  final String refundType;
  final String paymentMode;
  final String? cashBankAccountId;
  final String? referenceNo;
  final String? notes;

  PurchaseReturnPayload({
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    this.supplierGstNo,
    this.address,
    required this.originalPurchaseId,
    required this.originalPurchaseNo,
    this.billDate,
    required this.returnDate,
    this.stateOfSupply,
    required this.items,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.roundOff,
    required this.grandTotal,
    required this.refundType,
    required this.paymentMode,
    this.cashBankAccountId,
    this.referenceNo,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final String pMode = refundType == 'refund_received'
        ? paymentMode
        : 'Credit';
    final String? accId =
        (refundType == 'refund_received' && paymentMode.toLowerCase() != 'cash')
        ? cashBankAccountId
        : null;

    return {
      'supplierId': supplierId,
      'supplier': supplierId,
      'supplierName': supplierName,
      if (supplierPhone != null && supplierPhone!.isNotEmpty)
        'supplierPhone': supplierPhone,
      if (supplierGstNo != null && supplierGstNo!.isNotEmpty)
        'supplierGstNo': supplierGstNo,
      if (address != null && address!.isNotEmpty) 'address': address,
      'originalPurchaseId': originalPurchaseId,
      'purchase': originalPurchaseId,
      'originalPurchaseNo': originalPurchaseNo,
      if (billDate != null && billDate!.isNotEmpty) 'billDate': billDate,
      'returnDate': returnDate,
      if (stateOfSupply != null && stateOfSupply!.isNotEmpty)
        'stateOfSupply': stateOfSupply,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'refundType': refundType,
      'paymentMode': pMode,
      if (accId != null && accId.isNotEmpty) 'cashBankAccountId': accId,
      if (referenceNo != null && referenceNo!.isNotEmpty)
        'referenceNo': referenceNo,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
