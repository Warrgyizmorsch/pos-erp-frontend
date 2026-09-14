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
              // Top Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'TOTAL STORES: ${controller.godowns.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Stock Transfer',
                        icon: const Icon(Icons.sync_alt_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        height: 36,
                        onPressed: () => Get.toNamed('/inventory/stock-transfer'),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Add Godown',
                        icon: const Icon(Icons.add, size: 16),
                        variant: AppButtonVariant.primary,
                        height: 36,
                        onPressed: () => GodownDialog.show(context),
                      ),
                    ],
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: AppRadius.md,
            ),
            child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      godown.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        godown.code,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    if (godown.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  ],
                ),
                const SizedBox(height: 4),
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
    );
  }
}
