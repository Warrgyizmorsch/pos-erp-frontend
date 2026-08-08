import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/cheque_list_controller.dart';
import '../widgets/cheque_form_dialog.dart';

class ChequeListView extends GetView<ChequeListController> {
  const ChequeListView({super.key});

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
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cheques Register & Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Track incoming received cheques and outgoing issued cheque clearances.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Record Cheque',
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: () => Get.dialog(const ChequeFormDialog()),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stat Cards
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PENDING CHEQUES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${controller.totalPendingAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CLEARED CHEQUES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${controller.totalClearedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BOUNCED CHEQUES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${controller.totalBouncedAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Toolbar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search cheque no, party or bank...',
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

                    // Status Dropdown
                    Obx(
                      () => SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.statusFilter.value,
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
                              value: 'All',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'Cleared',
                              child: Text('Cleared'),
                            ),
                            DropdownMenuItem(
                              value: 'Bounced',
                              child: Text('Bounced'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.statusFilter.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Data Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final list = controller.filteredCheques;
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No Cheque Records Found',
                      description:
                          'Record a new cheque entry to begin tracking.',
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: WidgetStateProperty.all(
                            isDark ? AppColors.inputDark : Colors.grey[100],
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'CHEQUE NO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'TYPE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
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
                                'BANK NAME',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'DATE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                'AMOUNT (₹)',
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
                              numeric: true,
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
                          rows: list.map((c) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    c.chequeNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(_buildTypeBadge(c.type)),
                                DataCell(
                                  Text(
                                    c.partyName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    c.bankName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    c.date.split('T')[0],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${c.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(_buildStatusBadge(c.status)),
                                DataCell(
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        Get.dialog(ChequeFormDialog(cheque: c));
                                      } else if (val == 'clear') {
                                        controller.updateStatus(c, 'Cleared');
                                      } else if (val == 'bounce') {
                                        controller.updateStatus(c, 'Bounced');
                                      } else if (val == 'delete') {
                                        controller.deleteCheque(c.id);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Record'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'clear',
                                        child: Text('Mark as Cleared'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'bounce',
                                        child: Text('Mark as Bounced'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete Cheque'),
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
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final isReceived = type.toLowerCase() == 'received';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isReceived ? AppColors.success : AppColors.info).withAlpha(20),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isReceived ? AppColors.success : AppColors.info,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.info;
    final s = status.toLowerCase();
    if (s == 'cleared') bg = AppColors.success;
    if (s == 'pending') bg = AppColors.warning;
    if (s == 'bounced' || s == 'cancelled') bg = AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withAlpha(20),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bg),
      ),
    );
  }
}
