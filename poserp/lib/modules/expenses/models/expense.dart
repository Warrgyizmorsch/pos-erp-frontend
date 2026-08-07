import 'expense_category.dart';

class Expense {
  final String id;
  final String expenseNumber;
  final String title;
  final double amount;
  final ExpenseCategory? category;
  final String categoryName;
  final String date;
  final String paymentMethod;
  final String? cashBankAccountId;
  final String? referenceNo;
  final String? description;
  final String entryType;
  final String status;
  final String? createdBy;
  final String createdAt;

  Expense({
    required this.id,
    required this.expenseNumber,
    required this.title,
    required this.amount,
    this.category,
    required this.categoryName,
    required this.date,
    required this.paymentMethod,
    this.cashBankAccountId,
    this.referenceNo,
    this.description,
    required this.entryType,
    required this.status,
    this.createdBy,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    ExpenseCategory? cat;
    String catName = json['categoryName']?.toString() ?? 'General';

    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        try {
          cat = ExpenseCategory.fromJson(
            json['category'] as Map<String, dynamic>,
          );
          catName = cat.name;
        } catch (_) {
          catName = json['category']['name']?.toString() ?? catName;
        }
      } else {
        catName = json['category'].toString();
      }
    }

    String creatorName = 'System';
    if (json['createdBy'] != null) {
      if (json['createdBy'] is Map<String, dynamic>) {
        creatorName = json['createdBy']['name']?.toString() ?? 'System';
      } else {
        creatorName = json['createdBy'].toString();
      }
    }

    return Expense(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      expenseNumber:
          json['expenseNumber']?.toString() ??
          json['receiptNo']?.toString() ??
          '',
      title:
          json['title']?.toString() ??
          json['name']?.toString() ??
          json['description']?.toString() ??
          'Expense Item',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: cat,
      categoryName: catName,
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      paymentMethod:
          json['paymentMethod']?.toString() ??
          json['paymentMode']?.toString() ??
          'Cash',
      cashBankAccountId:
          json['cashBankAccountId']?.toString() ??
          json['accountId']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      description: json['description']?.toString() ?? json['notes']?.toString(),
      entryType: json['entryType']?.toString() ?? 'expense',
      status: json['status']?.toString() ?? 'approved',
      createdBy: creatorName,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      if (category != null) 'category': category!.id,
      'categoryName': categoryName,
      'date': date,
      'paymentMethod': paymentMethod,
      if (cashBankAccountId != null && cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
      if (referenceNo != null && referenceNo!.isNotEmpty)
        'referenceNo': referenceNo,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'entryType': entryType,
    };
  }
}
