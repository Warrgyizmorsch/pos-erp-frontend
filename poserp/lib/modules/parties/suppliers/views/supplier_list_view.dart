import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../widgets/supplier_dialog.dart';

class SupplierListView extends GetView<SupplierController> {
  const SupplierListView({super.key});

  void _exportSuppliersToCSV(List<Supplier> suppliers) {
    if (suppliers.isEmpty) {
      Get.snackbar('No Data', 'No suppliers available to export.');
      return;
    }
    Get.snackbar(
      'Export Successful',
      'Exported ${suppliers.length} suppliers to CSV/Excel format.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withAlpha(40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Scaffold(
      appBar: AppTopBar(
        title: 'Suppliers & Vendors',
        subtitle: 'Manage vendor accounts & purchase ledgers',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 24),
            tooltip: 'Add Supplier',
            onPressed: () => SupplierDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSuppliers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar & Outstanding Filter Toggle & Export Button
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hintText: 'Search suppliers by name, GSTIN...',
                        onChanged: (val) => controller.onSearchChanged(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: controller.filterBalance.value
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        tooltip: 'Filter by outstanding balance',
                        onPressed: () => controller.toggleFilterBalance(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Export',
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      onPressed: () =>
                          _exportSuppliersToCSV(controller.suppliers),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Suppliers Data View (Data Table on Desktop, AppListCards on Mobile)
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(message: 'Loading suppliers...'),
                  );
                }

                if (controller.suppliers.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: 'No Suppliers Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No vendor records match your search criteria.'
                          : 'Add your first supplier contact to manage purchase bills.',
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
                                          'PARTY NAME',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'CONTACT',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PURCHASES',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'BALANCE',
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
                                    rows: controller.suppliers.map((s) {
                                      final balance = s.outstandingBalance != 0
                                          ? s.outstandingBalance
                                          : s.openingBalance;
                                      final isPayable =
                                          balance > 0 ||
                                          s.openingBalanceType == 'Payable';

                                      return DataRow(
                                        onSelectChanged: (_) =>
                                            SupplierDialog.show(
                                              context,
                                              supplier: s,
                                            ),
                                        cells: [
                                          // Party Name & GSTIN
                                          DataCell(
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withAlpha(25),
                                                  child: Text(
                                                    s.name.isNotEmpty
                                                        ? s.name[0]
                                                              .toUpperCase()
                                                        : 'S',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      s.name,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      s.gstNumber ?? 'NO GST',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontFamily: 'monospace',
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Contact (Phone & Email)
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s.phone ?? '—',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  s.email ?? '—',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Purchases Count Badge
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.inputDark
                                                    : Colors.grey[200],
                                                borderRadius: AppRadius.full,
                                              ),
                                              child: Text(
                                                '${s.totalPurchases}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Balance Amount
                                          DataCell(
                                            Text(
                                              '₹${balance.abs().toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isPayable
                                                    ? Colors.red
                                                    : Colors.green,
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
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () =>
                                                      SupplierDialog.show(
                                                        context,
                                                        supplier: s,
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
                                                        s,
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
                          );
                        }

                        // Mobile View: AppListCards
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.suppliers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final supplier = controller.suppliers[index];
                            final balance = supplier.outstandingBalance != 0
                                ? supplier.outstandingBalance
                                : supplier.openingBalance;
                            final isPayable =
                                balance > 0 ||
                                supplier.openingBalanceType == 'Payable';

                            return AppListCard(
                              title: supplier.name,
                              subtitle:
                                  'GSTIN: ${supplier.gstNumber ?? "N/A"} • Phone: ${supplier.phone ?? "—"}',
                              trailingText: '₹${balance.toStringAsFixed(2)}',
                              statusText: isPayable
                                  ? 'PAYABLE'
                                  : 'PAID / CLEAR',
                              statusType: isPayable
                                  ? AppStatusChipType.danger
                                  : AppStatusChipType.success,
                              leadIcon: Icons.storefront_rounded,
                              onTap: () => SupplierDialog.show(
                                context,
                                supplier: supplier,
                              ),
                              popupMenu: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    SupplierDialog.show(
                                      context,
                                      supplier: supplier,
                                    );
                                  } else if (val == 'delete') {
                                    _showDeleteConfirm(context, supplier);
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
                                        Text('Edit Supplier'),
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
                                        Text('Delete Supplier'),
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
        heroTag: 'supplier_add_fab',
        onPressed: () => SupplierDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.storefront_rounded, color: Colors.white),
        label: const Text(
          'Add Supplier',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Supplier',
        description:
            'This action cannot be undone. All ledger history for supplier "${supplier.name}" will be permanently removed.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deleteSupplier(supplier.id);
        },
      ),
    );
  }
}
