import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/transporter_controller.dart';
import '../models/transporter.dart';
import '../widgets/transporter_dialog.dart';

class TransporterListView extends GetView<TransporterController> {
  const TransporterListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transporters'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Transporter',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => TransporterDialog.show(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage transport partners, drivers, and vehicles',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Search Bar
            AppSearchField(
              hintText: 'Search by name, vehicle number, phone...',
              onChanged: (val) => controller.onSearchChanged(val),
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading transporters...',
                  );
                }

                if (controller.transporters.isEmpty) {
                  return EmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: 'No Transporters Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No transporters match your search criteria.'
                        : 'Add your first transport partner to track vehicle dispatches.',
                    action: AppButton(
                      text: 'Add Transporter',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => TransporterDialog.show(context),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? AppColors.cardDark : Colors.grey[100],
                              ),
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Transporter')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Vehicle Number')),
                                DataColumn(label: Text('Address')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.transporters.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final transporter = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${((controller.currentPage.value - 1) * controller.itemsPerPage) + idx + 1}',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForegroundLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Transporter Info with Truck Avatar
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.cyan,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(17),
                                            ),
                                            child: const Icon(
                                              Icons.local_shipping,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            transporter.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(transporter.phone)),
                                    DataCell(
                                      Text(
                                        transporter.vehicleNumber != null &&
                                                transporter
                                                    .vehicleNumber!
                                                    .isNotEmpty
                                            ? transporter.vehicleNumber!
                                            : '—',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        transporter.address != null &&
                                                transporter.address!.isNotEmpty
                                            ? transporter.address!
                                            : '—',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForegroundLight,
                                        ),
                                      ),
                                    ),
                                    // Status Badge
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: transporter.isActive
                                              ? AppColors.success.withValues(
                                                  alpha: 0.15,
                                                )
                                              : Colors.grey[300],
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          transporter.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: transporter.isActive
                                                ? AppColors.success
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Actions
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            color: AppColors.primary,
                                            onPressed: () =>
                                                TransporterDialog.show(
                                                  context,
                                                  transporter: transporter,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            color: AppColors.danger,
                                            onPressed: () => _showDeleteConfirm(
                                              context,
                                              transporter,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pagination Controls
                    Obx(
                      () => AppPagination(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPageChanged: (page) => controller.goToPage(page),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Transporter transporter) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Transporter',
        description:
            'This action cannot be undone. Are you sure you want to delete transporter "${transporter.name}"?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deleteTransporter(transporter.id);
        },
      ),
    );
  }
}
