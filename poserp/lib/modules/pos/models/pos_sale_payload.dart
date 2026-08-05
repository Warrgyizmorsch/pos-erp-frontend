class POSSaleItemPayload {
  final String? product;
  final String? productId;
  final String itemType;
  final bool affectsInventory;
  final String itemName;
  final String description;
  final String sku;
  final double quantity;
  final double rate;
  final double unitPrice;
  final double purchasePrice;
  final double discount;
  final double taxRate;
  final double gstRate;
  final double taxableAmount;
  final double taxAmount;
  final double totalAmount;
  final double cgst;
  final double cgstAmount;
  final double sgst;
  final double sgstAmount;
  final double igst;
  final double igstAmount;
  final String hsn;
  final String? incomeLedger;
  final double total;

  POSSaleItemPayload({
    this.product,
    this.productId,
    required this.itemType,
    required this.affectsInventory,
    required this.itemName,
    required this.description,
    required this.sku,
    required this.quantity,
    required this.rate,
    required this.unitPrice,
    required this.purchasePrice,
    required this.discount,
    required this.taxRate,
    required this.gstRate,
    required this.taxableAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.cgst,
    required this.cgstAmount,
    required this.sgst,
    required this.sgstAmount,
    required this.igst,
    required this.igstAmount,
    required this.hsn,
    this.incomeLedger,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'productId': productId,
      'itemType': itemType,
      'affectsInventory': affectsInventory,
      'itemName': itemName,
      'name': itemName,
      'description': description,
      'sku': sku,
      'quantity': quantity,
      'rate': rate,
      'unitPrice': unitPrice,
      'purchasePrice': purchasePrice,
      'discount': discount,
      'taxRate': taxRate,
      'gstRate': gstRate,
      'taxableAmount': taxableAmount,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'cgst': cgst,
      'cgstAmount': cgstAmount,
      'sgst': sgst,
      'sgstAmount': sgstAmount,
      'igst': igst,
      'igstAmount': igstAmount,
      'hsn': hsn,
      'incomeLedger': incomeLedger,
      'total': total,
    };
  }
}

class POSSalePayload {
  final String? customer;
  final String customerName;
  final String saleDate;
  final List<POSSaleItemPayload> items;
  final double subtotal;
  final double taxAmount;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String notes;
  final String? cashBankAccountId;

  POSSalePayload({
    this.customer,
    required this.customerName,
    required this.saleDate,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.discountAmount,
    required this.totalAmount,
    required this.amountPaid,
    this.status = 'completed',
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes = '',
    this.cashBankAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (customer != null && customer!.isNotEmpty && customer != 'walk-in')
        'customer': customer,
      'customerName': customerName,
      'saleDate': saleDate,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'totalIgst': totalIgst,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      if (cashBankAccountId != null && cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
    };
  }
}
