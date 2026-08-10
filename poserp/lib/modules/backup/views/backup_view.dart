import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/backup_controller.dart';
import '../models/backup_info.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Sync, Share & Backup',
        subtitle: 'Secure ERP database snapshots & restore points',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh History',
            onPressed: () => controller.loadBackups(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadBackups(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Cards Bar (Responsive Mobile Grid)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  final localCard = AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(
                              Icons.sd_storage_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            Text(
                              'LOCAL STORAGE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Local Backup',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Export JSON snapshot to drive.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => AppButton(
                            text: controller.isExporting.value
                                ? 'Exporting...'
                                : 'Backup Now',
                            variant: AppButtonVariant.primary,
                            width: double.infinity,
                            height: 38,
                            onPressed: controller.isExporting.value
                                ? null
                                : () => controller.triggerBackup(type: 'local'),
                          ),
                        ),
                      ],
                    ),
                  );

                  final cloudCard = AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(
                              Icons.cloud_done_outlined,
                              color: AppColors.info,
                              size: 22,
                            ),
                            Text(
                              'CLOUD STORAGE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cloud Snapshot',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sync database to remote drive.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => AppButton(
                            text: controller.isExporting.value
                                ? 'Uploading...'
                                : 'Upload Cloud',
                            variant: AppButtonVariant.secondary,
                            width: double.infinity,
                            height: 38,
                            onPressed: controller.isExporting.value
                                ? null
                                : () => controller.triggerBackup(type: 'cloud'),
                          ),
                        ),
                      ],
                    ),
                  );

                  final syncCard = AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.sync_outlined,
                              color: AppColors.success,
                              size: 22,
                            ),
                            Obx(
                              () => Switch(
                                value: controller.autoSyncEnabled.value,
                                activeThumbColor: AppColors.success,
                                onChanged: (val) =>
                                    controller.autoSyncEnabled.value = val,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Automated Daily Sync',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Auto-backup every midnight.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(20),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Text(
                            'Status: ACTIVE (00:00 UTC)',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isMobile) {
                    return Column(
                      children: [
                        localCard,
                        const SizedBox(height: 10),
                        cloudCard,
                        const SizedBox(height: 10),
                        syncCard,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: localCard),
                      const SizedBox(width: 12),
                      Expanded(child: cloudCard),
                      const SizedBox(width: 12),
                      Expanded(child: syncCard),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Recent Backups History List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading backup history...',
                    ),
                  );
                }

                if (controller.backups.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'No Backups Created Yet',
                      description:
                          'Click "Backup Now" to generate your first ERP database snapshot.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.backups.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final b = controller.backups[index];

                    return AppListCard(
                      title: b.filename,
                      subtitle:
                          'Type: ${b.type.toUpperCase()} • Size: ${b.formattedSize} • Date: ${b.createdAt.split("T")[0]}',
                      trailingText: 'COMPLETED',
                      statusText: b.type.toUpperCase(),
                      statusType: b.type == 'cloud'
                          ? AppStatusChipType.info
                          : AppStatusChipType.success,
                      leadIcon: Icons.description_outlined,
                      popupMenu: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'restore') {
                            _showRestoreConfirm(context, b);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'restore',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.restore_rounded,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                SizedBox(width: 8),
                                Text('Restore Snapshot'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showRestoreConfirm(BuildContext context, BackupInfo b) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: const Text('Confirm Data Restore'),
        content: Text(
          'Are you sure you want to restore ERP database state from ${b.filename}? Current unsaved changes may be overwritten.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              controller.restore(b.id);
            },
            child: const Text('Confirm Restore'),
          ),
        ],
      ),
    );
  }
}
