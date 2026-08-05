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
  final String accountingStatus; // 'posted', 'failed', 'not_posted'
  final String? accountingError;
  final dynamic accountingVoucherId;
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
    this.accountingStatus = 'not_posted',
    this.accountingError,
    this.accountingVoucherId,
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
      accountingStatus: json['accountingStatus']?.toString() ?? 'not_posted',
      accountingError: json['accountingError']?.toString(),
      accountingVoucherId: json['accountingVoucherId'],
      createdAt: json['createdAt']?.toString(),
    );
  }

  double get balanceDue =>
      (totalAmount - amountPaid).clamp(0.0, double.infinity);
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
