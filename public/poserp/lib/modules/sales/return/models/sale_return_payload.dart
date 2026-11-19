class SaleReturnItemPayload {
  final String? product;
  final String? saleItemId;
  final String itemType;
  final bool affectsInventory;
  final String barcode;
  final String itemName;
  final double soldQty;
  final double alreadyReturnedQty;
  final double returnQty;
  final String unit;
  final double pricePerUnit;
  final double discountAmount;
  final double taxPercent;
  final String reason;
  final String stockAction;

  SaleReturnItemPayload({
    this.product,
    this.saleItemId,
    required this.itemType,
    required this.affectsInventory,
    required this.barcode,
    required this.itemName,
    required this.soldQty,
    required this.alreadyReturnedQty,
    required this.returnQty,
    required this.unit,
    required this.pricePerUnit,
    required this.discountAmount,
    required this.taxPercent,
    required this.reason,
    required this.stockAction,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'saleItemId': saleItemId,
      'itemType': itemType,
      'affectsInventory': affectsInventory,
      'barcode': barcode,
      'itemName': itemName,
      'soldQty': soldQty,
      'alreadyReturnedQty': alreadyReturnedQty,
      'returnQty': returnQty,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'discountAmount': discountAmount,
      'taxPercent': taxPercent,
      'reason': reason,
      'stockAction': stockAction,
    };
  }
}

class SaleReturnPayload {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerGstNo;
  final String billingAddress;
  final String originalInvoiceId;
  final String originalInvoiceNo;
  final String? invoiceDate;
  final String returnDate;
  final String stateOfSupply;
  final List<SaleReturnItemPayload> items;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double roundOff;
  final double grandTotal;
  final String refundType;
  final String paymentMode;
  final String? cashBankAccountId;
  final String referenceNo;
  final String notes;

  SaleReturnPayload({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerGstNo,
    required this.billingAddress,
    required this.originalInvoiceId,
    required this.originalInvoiceNo,
    this.invoiceDate,
    required this.returnDate,
    required this.stateOfSupply,
    required this.items,
    required this.subtotal,
    required this.totalDiscount,
    required this.totalTax,
    required this.roundOff,
    required this.grandTotal,
    required this.refundType,
    required this.paymentMode,
    this.cashBankAccountId,
    this.referenceNo = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerGstNo': customerGstNo,
      'billingAddress': billingAddress,
      'originalInvoiceId': originalInvoiceId,
      'originalInvoiceNo': originalInvoiceNo,
      'invoiceDate': invoiceDate,
      'returnDate': returnDate,
      'stateOfSupply': stateOfSupply,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'refundType': refundType,
      'paymentMode': paymentMode,
      if (cashBankAccountId != null && cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
      'referenceNo': referenceNo,
      'notes': notes,
    };
  }
}
