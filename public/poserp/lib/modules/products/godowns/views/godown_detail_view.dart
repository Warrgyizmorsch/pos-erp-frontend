import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/godown_controller.dart';
import '../models/godown_inventory.dart';

class GodownDetailView extends StatefulWidget {
  const GodownDetailView({super.key});

  @override
  State<GodownDetailView> createState() => _GodownDetailViewState();
}

class _GodownDetailViewState extends State<GodownDetailView> {
  final GodownController controller = Get.find<GodownController>();
  late final String godownId;

  @override
  void initState() {
    super.initState();
    godownId = Get.parameters['id'] ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (godownId.isNotEmpty) {
        controller.loadGodownDetails(godownId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Godown Inventory',
        subtitle: 'Warehouse batch stock & pricing breakdown',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingInventory.value && controller.selectedGodown.value == null) {
          return const Center(child: LoadingIndicator());
        }

        final godown = controller.selectedGodown.value;
        if (godown == null && !controller.isLoadingInventory.value) {
          return Center(
            child: EmptyState(
              title: 'Godown Not Found',
              description: 'The requested warehouse location does not exist or has been removed.',
              icon: Icons.store_mall_directory_outlined,
              action: AppButton(
                text: 'Go Back',
                variant: AppButtonVariant.outline,
                onPressed: () => Get.back(),
              ),
            ),
          );
        }

        final inventory = controller.godownInventory;

        return RefreshIndicator(
          onRefresh: () async {
            if (godownId.isNotEmpty) {
              await controller.loadGodownDetails(godownId);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Godown Info Header Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  godown?.name ?? '',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    borderRadius: AppRadius.full,
                                  ),
                                  child: Text(
                                    godown?.code ?? '',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                if (godown?.isDefault ?? false)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withAlpha(20),
                                      borderRadius: AppRadius.full,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 12, color: AppColors.success),
                                        SizedBox(width: 4),
                                        Text(
                                          'Default Godown',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (godown?.isActive ?? true)
                                        ? AppColors.primary.withAlpha(15)
                                        : Colors.grey.withAlpha(20),
                                    borderRadius: AppRadius.full,
                                  ),
                                  child: Text(
                                    (godown?.isActive ?? true) ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: (godown?.isActive ?? true) ? AppColors.primary : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (godown?.location != null && godown!.location!.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    godown.location!,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: AppRadius.md,
                          border: Border.all(color: AppColors.primary.withAlpha(40)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'UNIQUE ITEMS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${inventory.length}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Header
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Inventory Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (controller.isLoadingInventory.value) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Detailed view of all products stored in this godown, separated by purchase and sale price batches.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 14),

                // Products & Batches
                if (inventory.isEmpty)
                  const AppCard(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: EmptyState(
                        title: 'This godown is currently empty.',
                        description: 'No product batches are currently assigned or stocked in this godown.',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inventory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      return _buildProductInventoryCard(item, isDark);
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProductInventoryCard(GodownInventoryItem item, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${item.product.sku}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '${item.totalQuantity} ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                      ),
                      children: [
                        TextSpan(
                          text: item.product.unit.isNotEmpty ? item.product.unit : 'units',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Total Quantity',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Batches
          if (item.batches.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                borderRadius: AppRadius.sm,
                border: Border.all(color: Colors.grey.withAlpha(40)),
              ),
              child: const Text(
                'Out of Stock in this Godown',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          else
            Column(
              children: item.batches.map((batch) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    borderRadius: AppRadius.sm,
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PURCHASED AT',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${batch.purchasePrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELLING AT',
                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${batch.salePrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'AVAILABLE',
                              style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${batch.quantity}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
