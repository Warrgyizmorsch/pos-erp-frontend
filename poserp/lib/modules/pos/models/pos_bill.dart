import '../../parties/customers/models/customer.dart';
import 'pos_item.dart';

final Customer walkInCustomer = Customer(
  id: 'walk-in',
  name: 'Walk-in Customer',
  phone: '',
  email: '',
  address: '',
);

class POSBill {
  final String id;
  final String? editingId;
  final int billNo;
  final Customer? customer;
  final List<POSItem> items;
  final int selectedRowIndex;
  final String
  paymentMode; // 'Cash', 'UPI', 'Card', 'Bank', 'Wallet', 'Partial'
  final double amountReceived;
  final double discount;
  final double additionalCharges;
  final String remarks;
  final String? cashBankAccountId;

  POSBill({
    required this.id,
    this.editingId,
    required this.billNo,
    this.customer,
    required this.items,
    this.selectedRowIndex = 0,
    this.paymentMode = 'Cash',
    this.amountReceived = 0,
    this.discount = 0,
    this.additionalCharges = 0,
    this.remarks = '',
    this.cashBankAccountId,
  });

  POSBill copyWith({
    String? id,
    String? editingId,
    int? billNo,
    Customer? customer,
    List<POSItem>? items,
    int? selectedRowIndex,
    String? paymentMode,
    double? amountReceived,
    double? discount,
    double? additionalCharges,
    String? remarks,
    String? cashBankAccountId,
  }) {
    return POSBill(
      id: id ?? this.id,
      editingId: editingId ?? this.editingId,
      billNo: billNo ?? this.billNo,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      selectedRowIndex: selectedRowIndex ?? this.selectedRowIndex,
      paymentMode: paymentMode ?? this.paymentMode,
      amountReceived: amountReceived ?? this.amountReceived,
      discount: discount ?? this.discount,
      additionalCharges: additionalCharges ?? this.additionalCharges,
      remarks: remarks ?? this.remarks,
      cashBankAccountId: cashBankAccountId ?? this.cashBankAccountId,
    );
  }

  double get grandTotal {
    final validItems = items.where((i) => i.itemName.isNotEmpty);
    return validItems.fold(0.0, (sum, item) => sum + item.total);
  }

  int get totalItems {
    return items.where((i) => i.itemName.isNotEmpty).length;
  }

  double get totalQuantity {
    return items
        .where((i) => i.itemName.isNotEmpty)
        .fold(0.0, (sum, item) => sum + item.quantity);
  }
}
