import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/godown_controller.dart';
import '../models/godown.dart';
import '../widgets/godown_dialog.dart';

class GodownListView extends GetView<GodownController> {
  const GodownListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Stores & Godowns',
        subtitle: 'Manage warehouse locations & multi-store inventory',
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt_rounded, size: 22),
            tooltip: 'Stock Transfer',
            onPressed: () => Get.toNamed('/inventory/stock-transfer'),
          ),
          IconButton(
            icon: const Icon(Icons.add_business_rounded, size: 22),
            tooltip: 'Add Godown',
            onPressed: () => GodownDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadGodowns(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern POS Overview Banner
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Multi-Warehouse & Stores',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Track stock across stores & transfer items seamlessly',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final total = controller.godowns.length;
                      final defaultStore = controller.godowns.firstWhereOrNull((g) => g.isDefault)?.name ?? 'None';
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(15),
                              borderRadius: AppRadius.full,
                              border: Border.all(color: AppColors.primary.withAlpha(40)),
                            ),
                            child: Text(
                              'Stores: $total',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(15),
                              borderRadius: AppRadius.full,
                              border: Border.all(color: AppColors.success.withAlpha(40)),
                            ),
                            child: Text(
                              'Default: $defaultStore',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Responsive Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Stock Transfer',
                      icon: const Icon(Icons.sync_alt_rounded, size: 16),
                      variant: AppButtonVariant.outline,
                      height: 40,
                      onPressed: () => Get.toNamed('/inventory/stock-transfer'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: 'Add Godown',
                      icon: const Icon(Icons.add_business_rounded, size: 16),
                      variant: AppButtonVariant.primary,
                      height: 40,
                      onPressed: () => GodownDialog.show(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Godowns List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: LoadingIndicator());
                }

                if (controller.godowns.isEmpty) {
                  return const EmptyState(
                    title: 'No Godowns / Stores Configured',
                    description: 'Add your primary store or warehouse to enable multi-location inventory tracking.',
                    icon: Icons.warehouse_rounded,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.godowns.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final godown = controller.godowns[index];
                    return _buildGodownCard(context, godown);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGodownCard(BuildContext context, Godown godown) {
    return InkWell(
      borderRadius: AppRadius.lg,
      onTap: () => Get.toNamed('/inventory/godowns/${godown.id}'),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: AppRadius.md,
              ),
              child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        godown.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          godown.code,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      if (godown.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(20),
                            borderRadius: AppRadius.full,
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    godown.location != null && godown.location!.isNotEmpty
                        ? 'Location: ${godown.location}'
                        : 'No specific location specified',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (godown.capacity > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Capacity: ${godown.capacity.toStringAsFixed(0)} units',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary),
                  tooltip: 'View Inventory',
                  onPressed: () => Get.toNamed('/inventory/godowns/${godown.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  tooltip: 'Edit Godown',
                  onPressed: () => GodownDialog.show(context, godown: godown),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                  tooltip: 'Delete Godown',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        title: 'Delete Godown',
                        description: 'Are you sure you want to delete ${godown.name}? Existing inventory records in this location will need to be reallocated.',
                        confirmLabel: 'Delete Godown',
                        onConfirm: () {
                          Navigator.pop(context);
                          controller.deleteGodown(godown.id);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
