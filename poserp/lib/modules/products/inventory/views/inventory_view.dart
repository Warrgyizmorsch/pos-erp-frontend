import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
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
      appBar: AppTopBar(
        title: 'Inventory Manager',
        subtitle: 'Stock monitoring, shift logs & adjustments',
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert_rounded, size: 24),
            tooltip: 'Record Stock Adjustment',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const StockAdjustmentDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Stock Valuation Banner
              Obx(
                () => AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL INVENTORY VALUATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${controller.totalInventoryValuation.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Segmented Tab Selector
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.grey[200],
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
                        label: 'Movements',
                        icon: Icons.history_rounded,
                      ),
                      _buildTabButton(
                        context,
                        id: 'adjustments',
                        label: 'Adjustments',
                        icon: Icons.tune_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Active Tab Content
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const StockAdjustmentDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.tune_rounded, color: Colors.white),
        label: const Text(
          'Adjust Stock',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
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

    return Expanded(
      child: InkWell(
        onTap: () => controller.activeTab.value = id,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.inputDark : Colors.white)
                : Colors.transparent,
            borderRadius: AppRadius.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: Current Stock List (Mobile View) ---
  Widget _buildCurrentStockTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search Input
        TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search stock by SKU, name or barcode...',
            prefixIcon: const Icon(Icons.search, size: 18),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark ? AppColors.cardDark : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: AppRadius.lg,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Products List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingCurrent.value) {
              return const LoadingIndicator(message: 'Fetching inventory...');
            }
            if (controller.products.isEmpty) {
              return const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No Stock Items Found',
                description:
                    'Try adjusting your search query or registering products.',
              );
            }

            return ListView.separated(
              itemCount: controller.products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = controller.products[index];
                final isLow = p.stock <= p.lowStockThreshold;
                final isOut = p.stock <= 0;

                AppStatusChipType statusType = AppStatusChipType.success;
                String statusText = 'IN STOCK';
                if (isOut) {
                  statusType = AppStatusChipType.danger;
                  statusText = 'OUT OF STOCK';
                } else if (isLow) {
                  statusType = AppStatusChipType.warning;
                  statusText = 'LOW STOCK';
                }

                return AppListCard(
                  title: p.name,
                  subtitle:
                      'SKU: ${p.sku} • Rate: ₹${p.purchasePrice.toStringAsFixed(2)}',
                  trailingText: '${p.stock} ${p.unit.toUpperCase()}',
                  statusText: statusText,
                  statusType: statusType,
                  leadIcon: Icons.inventory_2_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          StockAdjustmentDialog(initialProduct: p),
                    );
                  },
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- TAB 2: Stock Movement History (Mobile List) ---
  Widget _buildMovementsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => controller.historySearchQuery.value = val,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Filter movements by product...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.lg,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => DropdownButton<String>(
                value: controller.selectedHistoryType.value,
                dropdownColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'purchase', child: Text('Purchase')),
                  DropdownMenuItem(value: 'sale', child: Text('Sales')),
                  DropdownMenuItem(
                    value: 'adjustment',
                    child: Text('Adjustments'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedHistoryType.value = val;
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: Obx(() {
            if (controller.isLoadingHistory.value) {
              return const LoadingIndicator(message: 'Loading movements...');
            }
            if (controller.movements.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No Stock Movements Logged',
                description:
                    'Sales, purchases, and manual adjustments will record audit trails here.',
              );
            }

            return ListView.separated(
              itemCount: controller.movements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final m = controller.movements[index];
                final isPositive = m.quantity > 0;
                final dateStr = m.createdAt.split('T')[0];

                return AppListCard(
                  title: m.productName,
                  subtitle:
                      '$dateStr • Shift: ${m.previousStock} ➔ ${m.newStock}',
                  trailingText: isPositive ? '+${m.quantity}' : '${m.quantity}',
                  statusText: m.type.toUpperCase(),
                  statusType: isPositive
                      ? AppStatusChipType.success
                      : AppStatusChipType.danger,
                  leadIcon: isPositive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- TAB 3: Stock Adjustments Log ---
  Widget _buildAdjustmentsTab(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoadingAdjustments.value) {
        return const LoadingIndicator(message: 'Loading adjustments...');
      }
      if (controller.adjustments.isEmpty) {
        return const EmptyState(
          icon: Icons.tune_rounded,
          title: 'No Adjustments Recorded',
          description:
              'Record manual stock adjustments to fix audit discrepancies.',
        );
      }

      return ListView.separated(
        itemCount: controller.adjustments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final adj = controller.adjustments[index];
          final isAdd = adj.difference >= 0;

          return AppListCard(
            title: adj.productName,
            subtitle:
                'Reason: ${adj.reason} • ${adj.previousStock} ➔ ${adj.adjustedStock}',
            trailingText: isAdd
                ? '+${adj.difference.toStringAsFixed(0)}'
                : adj.difference.toStringAsFixed(0),
            statusText: isAdd ? 'STOCK ADDED' : 'STOCK REMOVED',
            statusType: isAdd
                ? AppStatusChipType.success
                : AppStatusChipType.danger,
            leadIcon: Icons.tune_rounded,
          );
        },
      );
    });
  }
}
