import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_audit_log_controller.dart';
import '../models/accounting_audit_log.dart';

class AccountingAuditLogView extends GetView<AccountingAuditLogController> {
  const AccountingAuditLogView({super.key});

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
                          Icons.history_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Accounting System Audit Trail',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Audit log history for settings updates, voucher posts, and reconciliation actions.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Refresh Audit Log',
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    onPressed: () => controller.loadLogs(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hintText: 'Search action or reference...',
                        prefixIcon: const Icon(Icons.search, size: 16),
                        onChanged: (val) {
                          controller.searchFilter.value = val;
                          controller.loadLogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: AppTextField(
                        hintText: 'Action',
                        onChanged: (val) {
                          controller.actionFilter.value = val;
                          controller.loadLogs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: AppTextField(
                        hintText: 'Module',
                        onChanged: (val) {
                          controller.moduleFilter.value = val;
                          controller.loadLogs();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            isDark ? AppColors.inputDark : Colors.grey[100],
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'DATE & TIME',
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
                                'REFERENCE',
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
                                DataCell(
                                  Text(
                                    log.createdAt.contains('T')
                                        ? log.createdAt.split('T').first
                                        : log.createdAt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    log.userName ?? 'System',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
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
                                      log.action,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    log.module,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    log.referenceNo ?? log.referenceId ?? '-',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  AppButton(
                                    text: 'View Diff',
                                    variant: AppButtonVariant.outline,
                                    onPressed: () =>
                                        _showDetailDialog(context, log),
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

  void _showDetailDialog(BuildContext context, AccountingAuditLog log) {
    const encoder = JsonEncoder.withIndent('  ');
    final oldStr = log.oldData != null ? encoder.convert(log.oldData) : '{}';
    final newStr = log.newData != null ? encoder.convert(log.newData) : '{}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Audit Entry: ${log.action}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User: ${log.userName ?? "System"} | IP: ${log.ipAddress ?? "-"}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Old Data:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    oldStr,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'New Data:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    newStr,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
