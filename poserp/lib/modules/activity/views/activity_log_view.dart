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

  Widget _buildActionBadge(String actionStr) {
    Color bg;
    Color text;

    switch (actionStr.toLowerCase()) {
      case 'create':
        bg = Colors.green.withAlpha(25);
        text = Colors.green;
        break;
      case 'update':
        bg = Colors.blue.withAlpha(25);
        text = Colors.blue;
        break;
      case 'delete':
      case 'cancel':
        bg = Colors.red.withAlpha(25);
        text = Colors.red;
        break;
      case 'login':
      case 'logout':
        bg = Colors.orange.withAlpha(25);
        text = Colors.orange;
        break;
      default:
        bg = Colors.amber.withAlpha(25);
        text = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.full,
        border: Border.all(color: text.withAlpha(50)),
      ),
      child: Text(
        actionStr.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header & Quick Actions
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Row(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Activity Logs',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Track all system activity, changes, and user sessions.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.hasActiveFilters)
                          AppButton(
                            text: 'Clear Filters',
                            variant: AppButtonVariant.outline,
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () => controller.clearFilters(),
                          ),
                        if (controller.hasActiveFilters)
                          const SizedBox(width: 8),
                        AppButton(
                          text: controller.isLoading.value
                              ? 'Loading...'
                              : 'Refresh',
                          icon: controller.isLoading.value
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.loadLogs(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Filter Toolbar Card (Responsive Grid Layout)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          int cols = 1;
                          if (width > 900) {
                            cols = 3;
                          } else if (width > 550) {
                            cols = 2;
                          }

                          final itemWidth =
                              (width - (cols - 1) * 12) / cols.toDouble();

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              // Search User
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Search User',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      onChanged: (val) =>
                                          controller.searchUser.value = val,
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Search user name...',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          size: 18,
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 10,
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
                                  ],
                                ),
                              ),

                              // Module Select Filter
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Module',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => DropdownButtonFormField<String>(
                                        initialValue:
                                            controller.selectedModule.value,
                                        dropdownColor: isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
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
                                            value: 'Subcategory',
                                            child: Text('Subcategory'),
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
                                            value: 'Transporter',
                                            child: Text('Transporter'),
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
                                            value: 'Sale',
                                            child: Text('Sale'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Purchase',
                                            child: Text('Purchase'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Auth',
                                            child: Text('Auth'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Inventory',
                                            child: Text('Inventory'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'CashBank',
                                            child: Text('CashBank'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.selectedModule.value =
                                                val;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Action Select Filter
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Action',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => DropdownButtonFormField<String>(
                                        initialValue:
                                            controller.selectedAction.value,
                                        dropdownColor: isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 10,
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
                                          DropdownMenuItem(
                                            value: 'stock_adjust',
                                            child: Text('Stock Adjust'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'sale',
                                            child: Text('Sale'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'purchase',
                                            child: Text('Purchase'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'cancel',
                                            child: Text('Cancel'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            controller.selectedAction.value =
                                                val;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Activity History Data Table
                if (controller.isLoading.value && controller.logs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: LoadingIndicator(),
                  )
                else
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.logs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: EmptyState(
                              icon: Icons.assignment_outlined,
                              title: 'No Activity Logs Found',
                              description:
                                  'Try relaxing your search or filter parameters.',
                            ),
                          )
                        else
                          ClipRRect(
                            borderRadius: AppRadius.lg,
                            child: Scrollbar(
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                controller: horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 24,
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
                                        'DETAILS',
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
                                        // Timestamp
                                        DataCell(
                                          Text(
                                            log.createdAt.contains('T')
                                                ? log.createdAt.split('T')[0]
                                                : log.createdAt,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),

                                        // User
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

                                        // Module
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withAlpha(20),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: Text(
                                              log.module,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Action Badge
                                        DataCell(_buildActionBadge(log.action)),

                                        // Description
                                        DataCell(
                                          SizedBox(
                                            width: 250,
                                            child: Text(
                                              log.description,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),

                                        // Details Action
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
                                                ActivityLogDetailDialog(
                                                  log: log,
                                                ),
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
                          ),

                        // Pagination Footer
                        if (controller.totalPages.value > 1)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    AppButton(
                                      text: 'Previous',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value <= 1
                                          ? null
                                          : () => controller.previousPage(),
                                    ),
                                    const SizedBox(width: 8),
                                    AppButton(
                                      text: 'Next',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value >=
                                              controller.totalPages.value
                                          ? null
                                          : () => controller.nextPage(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
