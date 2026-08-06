import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/stock_controller.dart';
import '../widgets/stock_adjustment_dialog.dart';

class InventoryView extends GetView<StockController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.warehouse_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Inventory Manager',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Monitor stock levels, track historical movements, and record inventory adjustments.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Valuation Card
                  Obx(
                    () => AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL INVENTORY VALUATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${controller.totalInventoryValuation.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Control Bar (Tabs & Action Buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tab Selector
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : Colors.grey[200],
                        borderRadius: AppRadius.lg,
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                            context,
                            id: 'current',
                            label: 'Current Stock',
                            icon: Icons.layers_outlined,
                          ),
                          _buildTabButton(
                            context,
                            id: 'history',
                            label: 'Stock Movement',
                            icon: Icons.history_rounded,
                          ),
                          _buildTabButton(
                            context,
                            id: 'adjustments',
                            label: 'Adjustments',
                            icon: Icons.swap_vert_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Action Button
                  AppButton(
                    text: 'Record Adjustment',
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const StockAdjustmentDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Tab Body
              Expanded(
                child: Obx(() {
                  switch (controller.activeTab.value) {
                    case 'history':
                      return _buildMovementsTab(context, isDark);
                    case 'adjustments':
                      return _buildAdjustmentsTab(context, isDark);
                    case 'current':
                    default:
                      return _buildCurrentStockTab(context, isDark);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = controller.activeTab.value == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => controller.activeTab.value = id,
      borderRadius: AppRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: AppRadius.md,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: Current Stock ---
  Widget _buildCurrentStockTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search Input
        TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search products by SKU, name or barcode...',
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Products Table
        Expanded(
          child: Obx(() {
            if (controller.isLoadingCurrent.value) {
              return const LoadingIndicator();
            }
            if (controller.products.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No Stock Items Found',
                description:
                    'Try adjusting your search criteria or adding products.',
              );
            }

            return AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadius.lg,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.inputDark : Colors.grey[100],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          '#',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PRODUCT DETAILS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'SKU / BARCODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PURCHASE PRICE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        numeric: true,
                        label: Text(
                          'CURRENT STOCK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'ACTION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(controller.products.length, (idx) {
                      final p = controller.products[idx];
                      final isLow = p.stock <= p.lowStockThreshold;
                      final isOut = p.stock <= 0;

                      Color statusColor = AppColors.success;
                      String statusText = 'In Stock';
                      if (isOut) {
                        statusColor = AppColors.danger;
                        statusText = 'Out of Stock';
                      } else if (isLow) {
                        statusColor = AppColors.warning;
                        statusText = 'Low Stock';
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Unit: ${p.unit}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              p.sku +
                                  (p.barcode != null && p.barcode!.isNotEmpty
                                      ? ' | ${p.barcode}'
                                      : ''),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '₹${p.purchasePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${p.stock} ${p.unit}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: AppRadius.full,
                                border: Border.all(
                                  color: statusColor.withAlpha(80),
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                size: 20,
                              ),
                              tooltip: 'Adjust Stock',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      StockAdjustmentDialog(initialProduct: p),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- TAB 2: Stock Movement History ---
  Widget _buildMovementsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            // Search Input
            Expanded(
              child: TextField(
                onChanged: (val) => controller.historySearchQuery.value = val,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Filter movements by product, reference ID...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.md,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Movement Type Filter
            Obx(
              () => SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: controller.selectedHistoryType.value,
                  dropdownColor: isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All Movements'),
                    ),
                    DropdownMenuItem(
                      value: 'purchase',
                      child: Text('Purchases (+)'),
                    ),
                    DropdownMenuItem(value: 'sale', child: Text('Sales (-)')),
                    DropdownMenuItem(value: 'return', child: Text('Returns')),
                    DropdownMenuItem(
                      value: 'adjustment',
                      child: Text('Adjustments'),
                    ),
                    DropdownMenuItem(
                      value: 'transfer',
                      child: Text('Transfers'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedHistoryType.value = val;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Movements Table
        Expanded(
          child: Obx(() {
            if (controller.isLoadingHistory.value) {
              return const LoadingIndicator();
            }
            if (controller.movements.isEmpty) {
              return EmptyState(
                icon: Icons.history_rounded,
                title: 'No Stock Movements Recorded',
                description:
                    'Historical movements from sales, purchases, and adjustments will appear here.',
              );
            }

            return AppCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AppRadius.lg,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.inputDark : Colors.grey[100],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'DATE & TIME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PRODUCT DETAILS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
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
                        numeric: true,
                        label: Text(
                          'CHANGE QTY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'STOCK SHIFT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'REFERENCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'OPERATOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                    rows: List.generate(controller.movements.length, (idx) {
                      final m = controller.movements[idx];
                      final isPositive = m.quantity > 0;
                      final dateStr = m.createdAt.split('T')[0];

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              m.productName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.inputDark
                                    : Colors.grey[200],
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                m.type.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              isPositive ? '+${m.quantity}' : '${m.quantity}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: isPositive
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${m.previousStock} ➔ ${m.newStock}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              m.reference ?? '—',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              m.createdBy ?? 'System',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- TAB 3: Stock Adjustments ---
  Widget _buildAdjustmentsTab(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoadingAdjustments.value) {
        return const LoadingIndicator();
      }
      if (controller.adjustments.isEmpty) {
        return EmptyState(
          icon: Icons.swap_vert_rounded,
          title: 'No Stock Adjustments Found',
          description:
              'Record a manual stock adjustment to fix count discrepancies.',
          action: AppButton(
            text: 'Record Adjustment',
            icon: const Icon(Icons.add, size: 18),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const StockAdjustmentDialog(),
              );
            },
          ),
        );
      }

      return AppCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: AppRadius.lg,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.inputDark : Colors.grey[100],
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'ADJUSTMENT NO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PRODUCT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'PREVIOUS STOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'ADJUSTED STOCK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'DIFFERENCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'REASON',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'OPERATOR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
              rows: List.generate(controller.adjustments.length, (idx) {
                final adj = controller.adjustments[idx];
                final diff = adj.difference;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        adj.adjustmentNumber.isNotEmpty
                            ? adj.adjustmentNumber
                            : '#ADJ-${idx + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        adj.productName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${adj.previousStock}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${adj.adjustedStock}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        diff >= 0 ? '+$diff' : '$diff',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: diff > 0
                              ? AppColors.success
                              : (diff < 0 ? AppColors.danger : Colors.grey),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(adj.reason, style: const TextStyle(fontSize: 12)),
                    ),
                    DataCell(
                      Text(
                        adj.createdBy ?? 'System',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
