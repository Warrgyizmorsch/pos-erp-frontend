import '../../parties/customers/models/customer.dart';
import 'sale_item.dart';

class Sale {
  final String id;
  final String invoiceNumber;
  final dynamic customer; // Customer or String ID
  final String customerName;
  final List<SaleItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final double changeAmount;
  final String status; // 'completed', 'cancelled', 'refunded'
  final String paymentStatus; // 'paid', 'pending', 'partial'
  final String paymentMethod; // 'cash', 'card', 'upi', 'bank', 'wallet'
  final String? notes;
  final String? cashBankAccountId;
  final String? godownId;
  final String accountingStatus; // 'posted', 'failed', 'not_posted'
  final String? accountingError;
  final dynamic accountingVoucherId;
  final String? irn;
  final String? qrCode;
  final String? eInvoiceStatus; // 'pending', 'generated', 'failed', 'not_applicable'
  final String? ewayBillNumber;
  final String? createdAt;

  Sale({
    required this.id,
    required this.invoiceNumber,
    this.customer,
    required this.customerName,
    required this.items,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.amountPaid = 0,
    this.changeAmount = 0,
    this.status = 'completed',
    this.paymentStatus = 'paid',
    this.paymentMethod = 'cash',
    this.notes,
    this.cashBankAccountId,
    this.godownId,
    this.accountingStatus = 'not_posted',
    this.accountingError,
    this.accountingVoucherId,
    this.irn,
    this.qrCode,
    this.eInvoiceStatus,
    this.ewayBillNumber,
    this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    dynamic cust;
    if (json['customer'] != null) {
      if (json['customer'] is Map<String, dynamic>) {
        cust = Customer.fromJson(json['customer']);
      } else {
        cust = json['customer'].toString();
      }
    }

    List<SaleItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((i) => SaleItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    String? gId;
    if (json['godownId'] != null) {
      if (json['godownId'] is Map<String, dynamic>) {
        gId = json['godownId']['_id']?.toString() ??
            json['godownId']['id']?.toString();
      } else {
        gId = json['godownId'].toString();
      }
    }

    return Sale(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      customer: cust,
      customerName: json['customerName']?.toString() ?? 'Walk-in Customer',
      items: itemList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'completed',
      paymentStatus: json['paymentStatus']?.toString() ?? 'paid',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      notes: json['notes']?.toString(),
      cashBankAccountId: json['cashBankAccountId']?.toString(),
      godownId: gId,
      accountingStatus: json['accountingStatus']?.toString() ?? 'not_posted',
      accountingError: json['accountingError']?.toString(),
      accountingVoucherId: json['accountingVoucherId'],
      irn: json['irn']?.toString(),
      qrCode: json['qrCode']?.toString(),
      eInvoiceStatus: json['eInvoiceStatus']?.toString(),
      ewayBillNumber: json['ewayBillNumber']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  double get balanceDue =>
      (totalAmount - amountPaid).clamp(0.0, double.infinity);

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customer': customer is Customer ? (customer as Customer).toJson() : customer,
      'customerName': customerName,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'changeAmount': changeAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'cashBankAccountId': cashBankAccountId,
      if (godownId != null && godownId!.isNotEmpty) 'godownId': godownId,
      'accountingStatus': accountingStatus,
      'accountingError': accountingError,
      'accountingVoucherId': accountingVoucherId,
      if (irn != null && irn!.isNotEmpty) 'irn': irn,
      if (qrCode != null && qrCode!.isNotEmpty) 'qrCode': qrCode,
      if (eInvoiceStatus != null && eInvoiceStatus!.isNotEmpty) 'eInvoiceStatus': eInvoiceStatus,
      if (ewayBillNumber != null && ewayBillNumber!.isNotEmpty) 'ewayBillNumber': ewayBillNumber,
      'createdAt': createdAt,
    };
  }
}

class SaleTotals {
  final double totalAmount;
  final double amountPaid;
  final double balanceAmount;

  SaleTotals({
    this.totalAmount = 0,
    this.amountPaid = 0,
    this.balanceAmount = 0,
  });

  factory SaleTotals.fromJson(Map<String, dynamic> json) {
    return SaleTotals(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
