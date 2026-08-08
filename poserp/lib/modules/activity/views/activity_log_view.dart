import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/activity_log_controller.dart';
import '../widgets/activity_log_detail_dialog.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

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
              // Header
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
                          Icons.assignment_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'System Activity Audit Logs',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Track system events, data mutations, stock adjustments, and user sessions.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => controller.hasActiveFilters
                            ? AppButton(
                                text: 'Clear Filters',
                                variant: AppButtonVariant.outline,
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () => controller.clearFilters(),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => controller.loadLogs(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Toolbar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (val) => controller.searchUser.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search user name...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.inputDark
                              : Colors.grey[100],
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
                    const SizedBox(width: 10),

                    // Module Filter
                    Obx(
                      () => SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedModule.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.inputDark
                                : Colors.grey[100],
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
                              child: Text('All Modules'),
                            ),
                            DropdownMenuItem(
                              value: 'Product',
                              child: Text('Product'),
                            ),
                            DropdownMenuItem(
                              value: 'Category',
                              child: Text('Category'),
                            ),
                            DropdownMenuItem(
                              value: 'Customer',
                              child: Text('Customer'),
                            ),
                            DropdownMenuItem(
                              value: 'Supplier',
                              child: Text('Supplier'),
                            ),
                            DropdownMenuItem(
                              value: 'Sale',
                              child: Text('Sale'),
                            ),
                            DropdownMenuItem(
                              value: 'Purchase',
                              child: Text('Purchase'),
                            ),
                            DropdownMenuItem(
                              value: 'Expense',
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: 'Shift',
                              child: Text('Shift'),
                            ),
                            DropdownMenuItem(
                              value: 'Auth',
                              child: Text('Auth'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedModule.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Action Filter
                    Obx(
                      () => SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedAction.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.inputDark
                                : Colors.grey[100],
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
                              child: Text('All Actions'),
                            ),
                            DropdownMenuItem(
                              value: 'create',
                              child: Text('Create'),
                            ),
                            DropdownMenuItem(
                              value: 'update',
                              child: Text('Update'),
                            ),
                            DropdownMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            DropdownMenuItem(
                              value: 'login',
                              child: Text('Login'),
                            ),
                            DropdownMenuItem(
                              value: 'logout',
                              child: Text('Logout'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedAction.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activity Log Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  if (controller.logs.isEmpty) {
                    return const EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No Activity Logs Found',
                      description: 'Try relaxing search or filter parameters.',
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 18,
                                headingRowColor: WidgetStateProperty.all(
                                  isDark
                                      ? AppColors.inputDark
                                      : Colors.grey[100],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'TIMESTAMP',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'USER',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'MODULE',
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
                                  DataColumn(
                                    label: Text(
                                      'DESCRIPTION',
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
                                rows: controller.logs.map((log) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          log.createdAt.split('T')[0],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log.userName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (log.ipAddress != null)
                                              Text(
                                                log.ipAddress!,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'monospace',
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(
                                              20,
                                            ),
                                            borderRadius: AppRadius.full,
                                          ),
                                          child: Text(
                                            log.module.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(_buildActionBadge(log.action)),
                                      DataCell(
                                        Text(
                                          log.description,
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DataCell(
                                        AppButton(
                                          text: 'Details',
                                          variant: AppButtonVariant.outline,
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 14,
                                          ),
                                          onPressed: () {
                                            Get.dialog(
                                              ActivityLogDetailDialog(log: log),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          // Pagination Controls Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.inputDark
                                  : Colors.grey[100],
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${controller.currentPage.value} of ${controller.totalPages.value} (${controller.totalRecords.value} records)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    AppButton(
                                      text: 'Previous',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value > 1
                                          ? () => controller.previousPage()
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    AppButton(
                                      text: 'Next',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value <
                                              controller.totalPages.value
                                          ? () => controller.nextPage()
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBadge(String action) {
    Color bg = AppColors.info;
    final a = action.toLowerCase();
    if (a.contains('create') || a.contains('add')) {
      bg = AppColors.success;
    } else if (a.contains('delete') || a.contains('cancel')) {
      bg = AppColors.danger;
    } else if (a.contains('login') || a.contains('logout')) {
      bg = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withAlpha(20),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        action.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bg),
      ),
    );
  }
}
