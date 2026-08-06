import '../../parties/suppliers/models/supplier.dart';
import 'purchase_item.dart';

class Purchase {
  final String id;
  final String purchaseNumber;
  final String? invoiceNumber;
  final dynamic supplier; // Supplier or String ID
  final String supplierName;
  final String? supplierPhone;
  final String? supplierGst;
  final String purchaseDate;
  final String? stateOfSupply;
  final String? transporter;
  final List<PurchaseItem> items;
  final double subtotal;
  final double discountAmount;
  final double shippingCharges;
  final double taxAmount;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final bool roundOff;
  final double totalAmount;
  final double amountPaid;
  final double dueAmount;
  final String
  status; // 'draft', 'confirmed', 'received', 'cancelled', 'returned'
  final String paymentStatus; // 'paid', 'pending', 'partial'
  final String paymentMethod; // 'cash', 'bank', 'upi', 'card'
  final String? cashBankAccountId;
  final String? notes;
  final String accountingStatus; // 'posted', 'failed', 'not_posted'
  final String? accountingError;
  final dynamic accountingVoucherId;
  final String? createdAt;

  Purchase({
    required this.id,
    required this.purchaseNumber,
    this.invoiceNumber,
    this.supplier,
    required this.supplierName,
    this.supplierPhone,
    this.supplierGst,
    required this.purchaseDate,
    this.stateOfSupply,
    this.transporter,
    required this.items,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.shippingCharges = 0,
    this.taxAmount = 0,
    this.totalCgst = 0,
    this.totalSgst = 0,
    this.totalIgst = 0,
    this.roundOff = false,
    this.totalAmount = 0,
    this.amountPaid = 0,
    this.dueAmount = 0,
    this.status = 'confirmed',
    this.paymentStatus = 'pending',
    this.paymentMethod = 'cash',
    this.cashBankAccountId,
    this.notes,
    this.accountingStatus = 'not_posted',
    this.accountingError,
    this.accountingVoucherId,
    this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    dynamic supp;
    String suppName = 'Supplier';
    String? suppPhone;
    String? suppGst;

    if (json['supplier'] != null) {
      if (json['supplier'] is Map<String, dynamic>) {
        final suppMap = json['supplier'] as Map<String, dynamic>;
        try {
          supp = Supplier.fromJson(suppMap);
          suppName = (supp as Supplier).name;
          suppPhone = supp.phone;
          suppGst = supp.gstNumber;
        } catch (_) {
          supp = suppMap['_id']?.toString() ?? suppMap['id']?.toString();
          suppName = suppMap['name']?.toString() ?? 'Supplier';
          suppPhone = suppMap['phone']?.toString();
          suppGst = suppMap['gstNumber']?.toString();
        }
      } else {
        supp = json['supplier'].toString();
      }
    }
    if (json['supplierName'] != null &&
        json['supplierName'].toString().isNotEmpty) {
      suppName = json['supplierName'].toString();
    }

    List<PurchaseItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      for (final i in json['items'] as List) {
        if (i is Map<String, dynamic>) {
          try {
            itemList.add(PurchaseItem.fromJson(i));
          } catch (_) {}
        }
      }
    }

    bool parseRoundOff(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return false;
    }

    final totAmt =
        (json['totalAmount'] as num?)?.toDouble() ??
        (json['total'] as num?)?.toDouble() ??
        0.0;
    final amtPaid = (json['amountPaid'] as num?)?.toDouble() ?? 0.0;
    final due =
        (json['dueAmount'] as num?)?.toDouble() ??
        (json['balance'] as num?)?.toDouble() ??
        (totAmt - amtPaid).clamp(0.0, double.infinity);

    final purNo =
        json['purchaseNumber']?.toString() ??
        json['purchaseNo']?.toString() ??
        json['invoiceNumber']?.toString() ??
        '';

    return Purchase(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      purchaseNumber: purNo,
      invoiceNumber:
          json['invoiceNumber']?.toString() ?? json['referenceNo']?.toString(),
      supplier: supp,
      supplierName: suppName,
      supplierPhone: suppPhone,
      supplierGst: suppGst,
      purchaseDate:
          json['purchaseDate']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      stateOfSupply: json['stateOfSupply']?.toString(),
      transporter: json['transporter']?.toString(),
      items: itemList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      shippingCharges: (json['shippingCharges'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalCgst: (json['totalCgst'] as num?)?.toDouble() ?? 0.0,
      totalSgst: (json['totalSgst'] as num?)?.toDouble() ?? 0.0,
      totalIgst: (json['totalIgst'] as num?)?.toDouble() ?? 0.0,
      roundOff: parseRoundOff(json['roundOff']),
      totalAmount: totAmt,
      amountPaid: amtPaid,
      dueAmount: due,
      status: json['status']?.toString() ?? 'confirmed',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      cashBankAccountId: json['cashBankAccountId']?.toString(),
      notes: json['notes']?.toString(),
      accountingStatus: json['accountingStatus']?.toString() ?? 'not_posted',
      accountingError: json['accountingError']?.toString(),
      accountingVoucherId: json['accountingVoucherId'],
      createdAt: json['createdAt']?.toString(),
    );
  }
}
