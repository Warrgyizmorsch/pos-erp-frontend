import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../widgets/supplier_dialog.dart';

class SupplierDetailView extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailView({super.key, required this.supplier});

  static void show(BuildContext context, Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SupplierDetailView(supplier: supplier),
    );
  }

  @override
  State<SupplierDetailView> createState() => _SupplierDetailViewState();
}

class _SupplierDetailViewState extends State<SupplierDetailView> {
  final SupplierController controller = Get.find<SupplierController>();
  bool isLoading = true;
  List<Map<String, dynamic>> ledgerEntries = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLedger();
    });
  }

  Future<void> _loadLedger() async {
    if (!isLoading && mounted) {
      setState(() => isLoading = true);
    }
    final entries = await controller.repository.getSupplierLedger(
      widget.supplier.id,
    );
    if (mounted) {
      setState(() {
        ledgerEntries = entries;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supplier = widget.supplier;
    final balance = supplier.outstandingBalance;
    final horizontalScrollController = ScrollController();

    final filteredLedger = ledgerEntries.where((t) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final type = (t['type'] ?? '').toString().toLowerCase();
      final no = (t['receiptNo'] ?? t['invoiceNumber'] ?? '').toString().toLowerCase();
      return type.contains(q) || no.contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            controller: scrollController,
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supplier Code: ${supplier.id.length > 8 ? supplier.id.substring(0, 8) : supplier.id}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Supplier',
                        onPressed: () {
                          Navigator.pop(context);
                          SupplierDialog.show(context, supplier: supplier);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overview Cards Row
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OUTSTANDING PAYABLE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: balance > 0 ? AppColors.danger : (balance < 0 ? AppColors.success : Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            balance > 0 ? 'You owe this supplier' : (balance < 0 ? 'Advance paid' : 'Account fully settled'),
                            style: TextStyle(
                              fontSize: 11,
                              color: balance > 0 ? AppColors.danger : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONTACT & GSTIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            supplier.phone ?? '—',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            supplier.gstNumber != null && supplier.gstNumber!.isNotEmpty
                                ? 'GST: ${supplier.gstNumber}'
                                : 'Unregistered Dealer',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contact Details Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VENDOR DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(supplier.email!, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (supplier.address != null && supplier.address!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(supplier.address!, style: const TextStyle(fontSize: 13))),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.account_balance_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Opening Balance: ₹${supplier.openingBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ledger Transactions
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TRANSACTION LEDGER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          onPressed: _loadLedger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isLoading)
                      const Padding(padding: EdgeInsets.all(24), child: Center(child: LoadingIndicator()))
                    else if (filteredLedger.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No ledger transactions recorded yet for this supplier.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      )
                    else
                      Scrollbar(
                        controller: horizontalScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 16,
                            headingRowColor: WidgetStateProperty.all(isDark ? AppColors.inputDark : Colors.grey[100]),
                            columns: const [
                              DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('REF #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('DEBIT (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('CREDIT (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('BALANCE (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredLedger.map((t) {
                              final debit = (t['debit'] as num?)?.toDouble() ?? 0.0;
                              final credit = (t['credit'] as num?)?.toDouble() ?? 0.0;
                              final bal = (t['balance'] as num?)?.toDouble() ?? 0.0;
                              final date = t['date']?.toString().split('T')[0] ?? '—';
                              final type = t['type']?.toString().toUpperCase() ?? 'ENTRY';
                              final ref = t['receiptNo'] ?? t['invoiceNumber'] ?? t['voucherNo'] ?? '—';

                              return DataRow(
                                cells: [
                                  DataCell(Text(date, style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                  DataCell(Text(ref.toString(), style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(debit > 0 ? '₹${debit.toStringAsFixed(2)}' : '—', style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                                  DataCell(Text(credit > 0 ? '₹${credit.toStringAsFixed(2)}' : '—', style: const TextStyle(color: AppColors.success, fontSize: 12))),
                                  DataCell(Text('₹${bal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Record Payment Out',
                    icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(context);
                      Get.toNamed('/payment-out');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
