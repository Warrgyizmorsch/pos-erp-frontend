class PurchaseItemPayload {
  final String? product;
  final String name;
  final String sku;
  final String barcode;
  final double quantity;
  final double purchasePrice;
  final double salesPrice;
  final double taxRate;
  final double total;

  PurchaseItemPayload({
    this.product,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.quantity,
    required this.purchasePrice,
    required this.salesPrice,
    required this.taxRate,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      if (product != null && product!.isNotEmpty) 'product': product,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'salesPrice': salesPrice,
      'taxRate': taxRate,
      'total': total,
    };
  }
}

class PurchasePayload {
  final String supplier;
  final String supplierName;
  final String? supplierPhone;
  final String? supplierGst;
  final String? invoiceNumber;
  final String purchaseDate;
  final String stateOfSupply;
  final String? transporter;
  final List<PurchaseItemPayload> items;
  final double subtotal;
  final double discountAmount;
  final double shippingCharges;
  final double taxAmount;
  final bool roundOff;
  final double totalAmount;
  final double amountPaid;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? cashBankAccountId;
  final String notes;

  PurchasePayload({
    required this.supplier,
    required this.supplierName,
    this.supplierPhone,
    this.supplierGst,
    this.invoiceNumber,
    required this.purchaseDate,
    required this.stateOfSupply,
    this.transporter,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingCharges,
    required this.taxAmount,
    required this.roundOff,
    required this.totalAmount,
    required this.amountPaid,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.cashBankAccountId,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'supplier': supplier,
      'supplierName': supplierName,
      if (supplierPhone != null) 'supplierPhone': supplierPhone,
      if (supplierGst != null) 'supplierGst': supplierGst,
      if (invoiceNumber != null && invoiceNumber!.isNotEmpty)
        'invoiceNumber': invoiceNumber,
      'purchaseDate': purchaseDate,
      'stateOfSupply': stateOfSupply,
      if (transporter != null &&
          transporter != 'none' &&
          transporter!.isNotEmpty)
        'transporter': transporter,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'shippingCharges': shippingCharges,
      'taxAmount': taxAmount,
      'roundOff': roundOff,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      if (paymentMethod.toLowerCase() != 'cash' &&
          cashBankAccountId != null &&
          cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
      'notes': notes,
    };
  }
}
