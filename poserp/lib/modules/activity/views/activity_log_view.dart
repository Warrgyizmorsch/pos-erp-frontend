import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/activity_log_controller.dart';
import '../models/activity_log.dart';
import '../widgets/activity_filter_sheet.dart';
import '../widgets/activity_log_card.dart';
import '../widgets/activity_log_detail_dialog.dart';

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadLogs(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header & Primary Action Buttons
                  _buildHeader(context, isDark, isMobile),
                  const SizedBox(height: 16),

                  // 2. Search Bar & Filter Launcher
                  _buildSearchAndFilterBar(context, isDark),
                  const SizedBox(height: 12),

                  // 3. Quick Filter Chips Bar
                  _buildQuickFilterChips(isDark),

                  // 4. Active Filters Removable Chips
                  if (controller.hasActiveFilters) ...[
                    const SizedBox(height: 10),
                    _buildActiveFilterChips(isDark),
                  ],

                  const SizedBox(height: 18),

                  // 5. Activity Log List (Mobile Cards vs Desktop Table)
                  if (controller.isLoading.value && controller.logs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: LoadingIndicator(),
                    )
                  else if (controller.logs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No Activity Logs Found',
                        description: controller.hasActiveFilters
                            ? 'No logs matched your active filters. Try clearing some filters.'
                            : 'System has no recorded activity logs yet.',
                      ),
                    )
                  else ...[
                    if (isMobile)
                      _buildMobileTimelineList(controller.logs)
                    else
                      _buildDesktopDataTable(context, isDark, controller.logs),

                    const SizedBox(height: 16),

                    // Pagination Footer
                    if (controller.totalPages.value > 1)
                      AppPagination(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPageChanged: (page) =>
                            controller.currentPage.value = page,
                      ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Activity Logs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.totalRecords.value > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.inputDark
                            : Colors.grey[200],
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        '${controller.totalRecords.value}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!isMobile) const SizedBox(height: 2),
              if (!isMobile)
                const Text(
                  'Track all system activity, changes, and user sessions.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        // Refresh Button
        IconButton(
          tooltip: 'Refresh Logs',
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.refresh_rounded),
          onPressed: controller.isLoading.value
              ? null
              : () => controller.loadLogs(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Search user or event
        Expanded(
          child: TextField(
            controller: TextEditingController(
              text: controller.searchUser.value,
            )..selection = TextSelection.fromPosition(
                TextPosition(offset: controller.searchUser.value.length),
              ),
            onChanged: (val) => controller.searchUser.value = val,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search user, action or keyword...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: controller.searchUser.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => controller.clearUserFilter(),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
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
              enabledBorder: OutlineInputBorder(
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
        const SizedBox(width: 8),

        // Filter Launcher Button with Badge Count
        Stack(
          clipBehavior: Clip.none,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                side: BorderSide(
                  color: controller.activeFilterCount > 0
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                ),
                backgroundColor: controller.activeFilterCount > 0
                    ? AppColors.primary.withAlpha(20)
                    : null,
              ),
              icon: Icon(
                Icons.tune_rounded,
                size: 18,
                color: controller.activeFilterCount > 0
                    ? AppColors.primary
                    : null,
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: controller.activeFilterCount > 0
                      ? AppColors.primary
                      : null,
                ),
              ),
              onPressed: () => ActivityFilterSheet.show(context, controller),
            ),
            if (controller.activeFilterCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${controller.activeFilterCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChips(bool isDark) {
    final quickOptions = [
      {'key': 'all', 'label': 'All'},
      {'key': 'today', 'label': 'Today'},
      {'key': 'sale', 'label': 'Sales'},
      {'key': 'purchase', 'label': 'Purchases'},
      {'key': 'login', 'label': 'Logins'},
      {'key': 'delete', 'label': 'Deletions'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickOptions.map((opt) {
          final isSelected =
              controller.selectedQuickFilter.value == opt['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(opt['label']!),
              selected: isSelected,
              onSelected: (_) => controller.setQuickFilter(opt['key']!),
              selectedColor: AppColors.primary.withAlpha(35),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveFilterChips(bool isDark) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (controller.searchUser.value.isNotEmpty)
          _buildDismissibleFilterChip(
            'User: "${controller.searchUser.value}"',
            () => controller.clearUserFilter(),
            isDark,
          ),
        if (controller.selectedModule.value != 'all')
          _buildDismissibleFilterChip(
            'Module: ${controller.selectedModule.value}',
            () => controller.clearModuleFilter(),
            isDark,
          ),
        if (controller.selectedAction.value != 'all')
          _buildDismissibleFilterChip(
            'Action: ${controller.selectedAction.value.toUpperCase()}',
            () => controller.clearActionFilter(),
            isDark,
          ),
        if (controller.startDate.value.isNotEmpty ||
            controller.endDate.value.isNotEmpty)
          _buildDismissibleFilterChip(
            controller.startDate.value == controller.endDate.value
                ? 'Date: ${controller.startDate.value}'
                : 'Date: ${controller.startDate.value}..${controller.endDate.value}',
            () => controller.clearDateFilter(),
            isDark,
          ),
        // Clear all text button
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => controller.clearFilters(),
          child: const Text(
            'Clear all',
            style: TextStyle(
              fontSize: 11,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleFilterChip(
    String label,
    VoidCallback onRemove,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 4, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: AppRadius.full,
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: AppRadius.full,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTimelineList(List<ActivityLog> logs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return ActivityLogCard(log: logs[index]);
      },
    );
  }

  Widget _buildDesktopDataTable(
    BuildContext context,
    bool isDark,
    List<ActivityLog> logs,
  ) {
    final horizontalScrollController = ScrollController();

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
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
                isDark ? AppColors.inputDark : Colors.grey[100],
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
              rows: logs.map((log) {
                final actionColor = ActivityLogCard.getActionColor(log.action);

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: AppColors.primary.withAlpha(20),
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
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: actionColor.withAlpha(25),
                          borderRadius: AppRadius.full,
                          border: Border.all(color: actionColor.withAlpha(50)),
                        ),
                        child: Text(
                          log.action.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                      ),
                    ),

                    // Description
                    DataCell(
                      SizedBox(
                        width: 250,
                        child: Text(
                          log.description,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Details Action Button
                    DataCell(
                      AppButton(
                        text: 'Details',
                        variant: AppButtonVariant.outline,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                        ),
                        onPressed: () {
                          Get.dialog(ActivityLogDetailDialog(log: log));
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
    );
  }
}
