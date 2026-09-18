import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../pos/widgets/pos_print_dialog.dart';
import '../controllers/sale_controller.dart';
import '../models/sale.dart';

class SaleDetailView extends StatefulWidget {
  const SaleDetailView({super.key});

  @override
  State<SaleDetailView> createState() => _SaleDetailViewState();
}

class _SaleDetailViewState extends State<SaleDetailView> {
  final SaleController controller = Get.find<SaleController>();
  final ScrollController horizontalScrollController = ScrollController();
  bool isLoading = true;
  Sale? sale;
  bool isReposting = false;

  @override
  void dispose() {
    horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSale();
    });
  }

  Future<void> _loadSale() async {
    final id = Get.parameters['id'] ?? controller.selectedSale.value?.id;
    if (id != null && id.isNotEmpty) {
      if (!isLoading && mounted) {
        setState(() => isLoading = true);
      }
      final fetched = await controller.fetchSaleById(id);
      if (mounted) {
        setState(() {
          sale = fetched;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          sale = controller.selectedSale.value;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _repostAccounting() async {
    if (sale == null) return;
    setState(() => isReposting = true);
    final ok = await controller.repostAccounting(sale!.id);
    if (ok) {
      await _loadSale();
    }
    if (mounted) {
      setState(() => isReposting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Sale Invoice Details'),
        body: const Center(child: LoadingIndicator()),
      );
    }

    if (sale == null) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Sale Invoice Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Sale invoice not found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              AppButton(
                text: 'Back to Sales',
                variant: AppButtonVariant.outline,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      );
    }

    final curSale = sale!;
    final dateStr = curSale.createdAt != null && curSale.createdAt!.contains('T')
        ? curSale.createdAt!.split('T')[0]
        : (curSale.createdAt ?? '—');

    return Scaffold(
      appBar: AppTopBar(
        title: 'Invoice #${curSale.invoiceNumber}',
        subtitle: 'B2B Sales Invoice & Accounting Voucher',
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 22),
            tooltip: 'Print Thermal Receipt',
            onPressed: () => POSPrintDialog.show(context, curSale.toJson()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: _loadSale,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSale,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;

                    final infoCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: AppRadius.md,
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    curSale.invoiceNumber,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Customer: ${curSale.customerName} • Date: $dateStr',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            AppStatusChip(
                              label: curSale.paymentStatus,
                              type: curSale.paymentStatus == 'paid'
                                  ? AppStatusChipType.success
                                  : (curSale.paymentStatus == 'partial'
                                      ? AppStatusChipType.warning
                                      : AppStatusChipType.danger),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: AppRadius.full,
                              ),
                              child: Text(
                                curSale.paymentMethod.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (curSale.status == 'completed' ? AppColors.success : AppColors.warning).withAlpha(20),
                                borderRadius: AppRadius.full,
                              ),
                              child: Text(
                                curSale.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: curSale.status == 'completed' ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );

                    final actionsCol = Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        if (isMobile) const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppButton(
                              text: 'Thermal Receipt',
                              icon: const Icon(Icons.receipt_rounded, size: 16),
                              variant: AppButtonVariant.outline,
                              height: 38,
                              onPressed: () => POSPrintDialog.show(context, curSale.toJson()),
                            ),
                            AppButton(
                              text: 'Edit in POS',
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              variant: AppButtonVariant.secondary,
                              height: 38,
                              onPressed: () => Get.toNamed('/pos', arguments: {'editSaleId': curSale.id}),
                            ),
                            AppButton(
                              text: 'Repost Ledger',
                              icon: const Icon(Icons.sync_rounded, size: 16),
                              variant: AppButtonVariant.outline,
                              height: 38,
                              isLoading: isReposting,
                              onPressed: _repostAccounting,
                            ),
                          ],
                        ),
                      ],
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [infoCol, actionsCol],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: infoCol),
                        const SizedBox(width: 16),
                        actionsCol,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;
                  final totalStr = '₹${curSale.totalAmount.toStringAsFixed(2)}';
                  final paidStr = '₹${curSale.amountPaid.toStringAsFixed(2)}';
                  final balStr = '₹${(curSale.totalAmount - curSale.amountPaid).clamp(0.0, double.infinity).toStringAsFixed(2)}';

                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: 140, child: AppStatCard(title: 'Total Amount', value: totalStr, icon: Icons.receipt_long_rounded)),
                          const SizedBox(width: 10),
                          SizedBox(width: 140, child: AppStatCard(title: 'Paid Amount', value: paidStr, icon: Icons.check_circle_outline_rounded)),
                          const SizedBox(width: 10),
                          SizedBox(width: 140, child: AppStatCard(title: 'Balance Due', value: balStr, icon: Icons.pending_actions_rounded)),
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: AppStatCard(title: 'Total Amount', value: totalStr, icon: Icons.receipt_long_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: AppStatCard(title: 'Paid Amount', value: paidStr, icon: Icons.check_circle_outline_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: AppStatCard(title: 'Balance Due', value: balStr, icon: Icons.pending_actions_rounded)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Line Items Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'LINE ITEMS & TAX BREAKDOWN',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        Text(
                          '${curSale.items.length} ${curSale.items.length == 1 ? "item" : "items"}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Scrollbar(
                      controller: horizontalScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateProperty.all(isDark ? AppColors.inputDark : Colors.grey[100]),
                          columns: const [
                            DataColumn(label: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('ITEM NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('HSN/SKU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('RATE (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('DISC (%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('TAX (%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('TOTAL (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                          rows: curSale.items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            final displayName = item.name != null && item.name!.isNotEmpty ? item.name! : item.itemName;
                            final displaySku = item.sku != null && item.sku!.isNotEmpty ? item.sku! : '—';

                            return DataRow(
                              cells: [
                                DataCell(Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(displaySku)),
                                DataCell(Text('${item.quantity.toInt()}')),
                                DataCell(Text('₹${item.rate.toStringAsFixed(2)}')),
                                DataCell(Text('${item.discount.toStringAsFixed(0)}%')),
                                DataCell(Text('${item.taxRate.toStringAsFixed(0)}%')),
                                DataCell(Text('₹${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Financial Summary & Notes
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;

                  final notesCard = AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notes_rounded, size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Text(
                              'INVOICE NOTES & REMARKS',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (curSale.notes != null && curSale.notes!.isNotEmpty)
                              ? curSale.notes!
                              : 'No notes recorded for this invoice.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );

                  final summaryCard = AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'PAYMENT & TOTALS BREAKDOWN',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Subtotal:', '₹${curSale.subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Total Tax (GST):', '₹${curSale.taxAmount.toStringAsFixed(2)}'),
                        if (curSale.discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          _buildSummaryRow('Total Discount:', '-₹${curSale.discountAmount.toStringAsFixed(2)}', valueColor: AppColors.danger),
                        ],
                        const Divider(height: 16),
                        _buildSummaryRow('Grand Total:', '₹${curSale.totalAmount.toStringAsFixed(2)}', isBold: true, fontSize: 16),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Amount Paid:', '₹${curSale.amountPaid.toStringAsFixed(2)}', isBold: true, valueColor: AppColors.success),
                        if (curSale.changeAmount > 0) ...[
                          const SizedBox(height: 6),
                          _buildSummaryRow('Change Returned:', '₹${curSale.changeAmount.toStringAsFixed(2)}', isBold: true, valueColor: AppColors.primary),
                        ],
                        const SizedBox(height: 6),
                        _buildSummaryRow('Balance Due:', '₹${(curSale.totalAmount - curSale.amountPaid).clamp(0.0, double.infinity).toStringAsFixed(2)}', isBold: true, valueColor: AppColors.danger),
                      ],
                    ),
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        summaryCard,
                        const SizedBox(height: 16),
                        notesCard,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: notesCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: summaryCard),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? null : Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
