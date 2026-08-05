import 'sale_return_item.dart';

class SaleReturn {
  final String id;
  final String creditNoteNo;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerGstNo;
  final String? originalInvoiceId;
  final String invoiceNumber;
  final String returnDate;
  final String? stateOfSupply;
  final List<SaleReturnItem> items;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double roundOff;
  final double grandTotal;
  final double refundedAmount;
  final double creditBalance;
  final String
  refundType; // 'refund_now', 'keep_as_credit', 'adjust_future_invoice'
  final String paymentMode; // 'Cash', 'UPI', 'Bank', 'Card', 'Credit'
  final String? cashBankAccountId;
  final String? referenceNo;
  final String? notes;
  final String status; // 'issued', 'refunded', 'adjusted', 'cancelled'
  final String accountingStatus; // 'posted', 'failed', 'not_posted'
  final String? createdAt;

  SaleReturn({
    required this.id,
    required this.creditNoteNo,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerGstNo,
    this.originalInvoiceId,
    required this.invoiceNumber,
    required this.returnDate,
    this.stateOfSupply,
    required this.items,
    this.subtotal = 0,
    this.totalDiscount = 0,
    this.totalTax = 0,
    this.roundOff = 0,
    this.grandTotal = 0,
    this.refundedAmount = 0,
    this.creditBalance = 0,
    this.refundType = 'refund_now',
    this.paymentMode = 'Cash',
    this.cashBankAccountId,
    this.referenceNo,
    this.notes,
    this.status = 'issued',
    this.accountingStatus = 'not_posted',
    this.createdAt,
  });

  factory SaleReturn.fromJson(Map<String, dynamic> json) {
    List<SaleReturnItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      itemList = (json['items'] as List)
          .map((i) => SaleReturnItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    final invNo =
        json['originalInvoiceNo']?.toString() ??
        json['invoiceNumber']?.toString() ??
        '';

    return SaleReturn(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      creditNoteNo: json['creditNoteNo']?.toString() ?? 'CN-001',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? 'Customer',
      customerPhone: json['customerPhone']?.toString(),
      customerGstNo: json['customerGstNo']?.toString(),
      originalInvoiceId: json['originalInvoiceId']?.toString(),
      invoiceNumber: invNo,
      returnDate:
          json['returnDate']?.toString() ?? DateTime.now().toIso8601String(),
      stateOfSupply: json['stateOfSupply']?.toString(),
      items: itemList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      roundOff: (json['roundOff'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0.0,
      creditBalance: (json['creditBalance'] as num?)?.toDouble() ?? 0.0,
      refundType: json['refundType']?.toString() ?? 'refund_now',
      paymentMode: json['paymentMode']?.toString() ?? 'Cash',
      cashBankAccountId: json['cashBankAccountId']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'issued',
      accountingStatus: json['accountingStatus']?.toString() ?? 'not_posted',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
