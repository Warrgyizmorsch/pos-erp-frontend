import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../widgets/customer_dialog.dart';

class CustomerDetailView extends StatefulWidget {
  final Customer customer;

  const CustomerDetailView({super.key, required this.customer});

  static void show(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CustomerDetailView(customer: customer),
    );
  }

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> {
  final CustomerController controller = Get.find<CustomerController>();
  bool isLoading = true;
  List<Map<String, dynamic>> ledgerEntries = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLedger();
  }

  Future<void> _loadLedger() async {
    setState(() => isLoading = true);
    final entries = await controller.repository.getCustomerLedger(
      widget.customer.id,
    );
    setState(() {
      ledgerEntries = entries;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customer = widget.customer;
    final balance = customer.walletBalance;

    final filteredLedger = ledgerEntries.where((t) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final type = (t['type'] ?? '').toString().toLowerCase();
      final no = (t['receiptNo'] ?? '').toString().toLowerCase();
      return type.contains(q) || no.contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            controller: scrollController,
            children: [
              // 1. Top Header Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Customer Profile & Ledger',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Edit Profile',
                    variant: AppButtonVariant.outline,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () {
                      Navigator.pop(context);
                      CustomerDialog.show(context, customer: customer);
                    },
                  ),
                ],
              ),
              const Divider(height: 24),

              // 2. Customer Info Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phone: ${customer.phone} ${(customer.email != null && customer.email!.isNotEmpty) ? "• ${customer.email}" : ""}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (customer.gstNumber != null &&
                                  customer.gstNumber!.isNotEmpty)
                                Text(
                                  'GSTIN: ${customer.gstNumber}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'OUTSTANDING BALANCE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${balance.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? Colors.green
                                    : (balance < 0 ? Colors.red : Colors.grey),
                              ),
                            ),
                            Text(
                              balance > 0
                                  ? 'RECEIVABLE'
                                  : (balance < 0 ? 'ADVANCE' : 'CLEAR'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? Colors.green
                                    : (balance < 0 ? Colors.red : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Transactions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ledger Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Search ledger...',
                        prefixIcon: Icon(Icons.search, size: 16),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ledger Data Table
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: LoadingIndicator(),
                )
              else if (filteredLedger.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No transactions found for this customer.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: AppRadius.lg,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.inputDark : Colors.grey[100],
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'TYPE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'NUMBER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DEBIT (SALE)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CREDIT (PAYMENT)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'OUTSTANDING BALANCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                        rows: filteredLedger.map((t) {
                          final type = (t['type'] ?? '')
                              .toString()
                              .replaceAll('_', ' ')
                              .toUpperCase();
                          final receiptNo =
                              (t['receiptNo'] ?? t['referenceId'] ?? '-')
                                  .toString();
                          final dateStr = (t['date'] ?? t['createdAt'] ?? '')
                              .toString();
                          final dt = dateStr.contains('T')
                              ? dateStr.split('T')[0]
                              : dateStr;
                          final debit = (t['debitAmount'] ?? 0.0) as num;
                          final credit = (t['creditAmount'] ?? 0.0) as num;
                          final balAfter = (t['balanceAfter'] ?? 0.0) as num;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  receiptNo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(dt, style: const TextStyle(fontSize: 11)),
                              ),
                              DataCell(
                                Text(
                                  debit > 0
                                      ? '+₹${debit.toStringAsFixed(2)}'
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  credit > 0
                                      ? '-₹${credit.toStringAsFixed(2)}'
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${balAfter.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // 4. Summary Footer Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL TRANSACTIONS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${ledgerEntries.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'CURRENT BALANCE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '₹${balance.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: balance > 0
                                ? Colors.green
                                : (balance < 0 ? Colors.red : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
