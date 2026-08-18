import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
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
    final horizontalScrollController = ScrollController();

    return Scaffold(
      appBar: AppTopBar(
        title: 'Transporters',
        subtitle: 'Manage transport partners & vehicle dispatch',
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined, size: 24),
            tooltip: 'Add Transporter',
            onPressed: () => TransporterDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadTransporters(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              AppCard(
                padding: const EdgeInsets.all(12),
                child: AppSearchField(
                  hintText: 'Search by transporter name, vehicle number...',
                  onChanged: (val) => controller.onSearchChanged(val),
                ),
              ),
              const SizedBox(height: 16),

              // Transporters Responsive Table / List View
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(message: 'Loading transporters...'),
                  );
                }

                if (controller.transporters.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'No Transporters Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No transport partners match your search query.'
                          : 'Register your first transport partner for logistics.',
                    ),
                  );
                }

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 700;

                        if (isDesktop) {
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
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                    ),
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'SR NO',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'TRANSPORTER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PHONE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'VEHICLE NUMBER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'ADDRESS',
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
                                          'ACTIONS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: controller.transporters
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final i = entry.key;
                                          final t = entry.value;

                                          return DataRow(
                                            onSelectChanged: (_) =>
                                                TransporterDialog.show(
                                                  context,
                                                  transporter: t,
                                                ),
                                            cells: [
                                              // Sr No
                                              DataCell(
                                                Text(
                                                  '${i + 1}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),

                                              // Transporter Name & Icon
                                              DataCell(
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: AppColors
                                                          .info
                                                          .withAlpha(25),
                                                      child: const Icon(
                                                        Icons.local_shipping,
                                                        size: 16,
                                                        color: AppColors.info,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      t.name,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Phone
                                              DataCell(
                                                Text(
                                                  t.phone,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),

                                              // Vehicle Number
                                              DataCell(
                                                Text(
                                                  t.vehicleNumber ?? '—',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              // Address
                                              DataCell(
                                                SizedBox(
                                                  width: 180,
                                                  child: Text(
                                                    t.address ?? '—',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Status Chip
                                              DataCell(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: t.isActive
                                                        ? Colors.green
                                                              .withAlpha(20)
                                                        : Colors.grey.withAlpha(
                                                            20,
                                                          ),
                                                    borderRadius:
                                                        AppRadius.full,
                                                  ),
                                                  child: Text(
                                                    t.isActive
                                                        ? 'ACTIVE'
                                                        : 'INACTIVE',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: t.isActive
                                                          ? Colors.green
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Actions (Edit & Delete Buttons)
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit_outlined,
                                                        size: 18,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      onPressed: () =>
                                                          TransporterDialog.show(
                                                            context,
                                                            transporter: t,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color: AppColors.danger,
                                                      ),
                                                      onPressed: () =>
                                                          _showDeleteConfirm(
                                                            context,
                                                            t,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Mobile View: AppListCards
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.transporters.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final transporter = controller.transporters[index];

                            return AppListCard(
                              title: transporter.name,
                              subtitle:
                                  'Vehicle: ${transporter.vehicleNumber ?? "N/A"} • Phone: ${transporter.phone}',
                              trailingText: transporter.address ?? '',
                              statusText: transporter.isActive
                                  ? 'ACTIVE'
                                  : 'INACTIVE',
                              statusType: transporter.isActive
                                  ? AppStatusChipType.success
                                  : AppStatusChipType.warning,
                              leadIcon: Icons.local_shipping_rounded,
                              onTap: () => TransporterDialog.show(
                                context,
                                transporter: transporter,
                              ),
                              popupMenu: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    TransporterDialog.show(
                                      context,
                                      transporter: transporter,
                                    );
                                  } else if (val == 'delete') {
                                    _showDeleteConfirm(context, transporter);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Edit Transporter'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: AppColors.danger,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete Transporter'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AppPagination(
                      currentPage: controller.currentPage.value,
                      totalPages: controller.totalPages.value,
                      onPageChanged: (page) => controller.goToPage(page),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'transporter_add_fab',
        onPressed: () => TransporterDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.local_shipping_rounded, color: Colors.white),
        label: const Text(
          'Add Transporter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
