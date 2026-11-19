import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_audit_log_controller.dart';
import '../models/accounting_audit_log.dart';

class AccountingAuditLogView extends GetView<AccountingAuditLogController> {
  const AccountingAuditLogView({super.key});

  String _compact(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) return '-';
    final text = jsonEncode(value);
    return text.length > 70 ? '${text.substring(0, 70)}...' : text;
  }

  String _pretty(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) return '{}';
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(value);
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final y = dt.year;
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$y-$m-$d $hh:$mm';
    } catch (_) {
      return isoString;
    }
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
                // 1. Header Navigation & Actions
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
                              Icons.history_rounded,
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
                                  'Accounting Audit Logs',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Track accounting settings, voucher, repost, and reconciliation activity.',
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
                          : const Icon(Icons.refresh_rounded, size: 16),
                      variant: AppButtonVariant.outline,
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.loadLogs(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Filter Card (6 Inputs Grid matching Next.js)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          int cols = 1;
                          if (width > 1100) {
                            cols = 6;
                          } else if (width > 750) {
                            cols = 3;
                          } else if (width > 480) {
                            cols = 2;
                          }

                          final itemWidth =
                              (width - (cols - 1) * 12) / cols.toDouble();

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              // From Date
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'From',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppTextField(
                                      hintText: 'YYYY-MM-DD',
                                      onChanged: (val) {
                                        controller.startDateFilter.value = val;
                                        controller.loadLogs();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // To Date
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppTextField(
                                      hintText: 'YYYY-MM-DD',
                                      onChanged: (val) {
                                        controller.endDateFilter.value = val;
                                        controller.loadLogs();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Action
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
                                    AppTextField(
                                      hintText: 'Action',
                                      onChanged: (val) {
                                        controller.actionFilter.value = val;
                                        controller.loadLogs();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Module
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
                                    AppTextField(
                                      hintText: 'Module',
                                      onChanged: (val) {
                                        controller.moduleFilter.value = val;
                                        controller.loadLogs();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // User
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'User',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppTextField(
                                      hintText: 'User',
                                      onChanged: (val) {
                                        controller.userFilter.value = val;
                                        controller.loadLogs();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Search
                              SizedBox(
                                width: itemWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Search',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AppTextField(
                                      hintText: 'Reference, description...',
                                      onChanged: (val) {
                                        controller.searchFilter.value = val;
                                        controller.loadLogs();
                                      },
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

                // 3. Data Table (All 9 Columns matching Next.js Table)
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
                              icon: Icons.history_rounded,
                              title: 'No accounting audit logs found',
                              description:
                                  'No records match your selected filter criteria.',
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
                                  headingRowColor: WidgetStateProperty.all(
                                    isDark
                                        ? AppColors.inputDark
                                        : Colors.grey[100],
                                  ),
                                  columnSpacing: 24,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Date & Time',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'User',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Action',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Module',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Reference',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Old Value',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'New Value',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'IP / Device',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Actions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: controller.logs.map((log) {
                                    return DataRow(
                                      cells: [
                                        // 1. Date & Time
                                        DataCell(
                                          Text(
                                            _formatDate(log.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),

                                        // 2. User
                                        DataCell(
                                          Text(
                                            log.userName ?? 'System',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),

                                        // 3. Action
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isDark
                                                    ? AppColors.borderDark
                                                    : Colors.grey[300]!,
                                              ),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: Text(
                                              log.action,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 4. Module
                                        DataCell(
                                          Text(
                                            log.module,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),

                                        // 5. Reference & Description
                                        DataCell(
                                          SizedBox(
                                            width: 220,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  log.referenceNo ??
                                                      log.referenceId ??
                                                      '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (log.description != null &&
                                                    log.description!.isNotEmpty)
                                                  Text(
                                                    log.description!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 6. Old Value
                                        DataCell(
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              _compact(log.oldData),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 7. New Value
                                        DataCell(
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              _compact(log.newData),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 8. IP / Device
                                        DataCell(
                                          SizedBox(
                                            width: 180,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  log.ipAddress ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                if (log.userAgent != null &&
                                                    log.userAgent!.isNotEmpty)
                                                  Text(
                                                    log.userAgent!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // 9. Actions Button
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: 18,
                                              color: AppColors.primary,
                                            ),
                                            tooltip: 'View details',
                                            onPressed: () =>
                                                _showDetailSheet(context, log),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
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

  // 4. Detail Sheet Drawer (Matching Next.js Sheet component)
  void _showDetailSheet(BuildContext context, AccountingAuditLog log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        log.action.isNotEmpty
                            ? log.action
                            : 'Audit Log Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // IP & User Agent Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                      borderRadius: AppRadius.md,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'IP Address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Text(
                              log.ipAddress ?? '-',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text(
                                'User Agent',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                log.userAgent ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Old Data Block
                  const Text(
                    'Old Data',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      borderRadius: AppRadius.md,
                    ),
                    child: Text(
                      _pretty(log.oldData),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New Data Block
                  const Text(
                    'New Data',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      borderRadius: AppRadius.md,
                    ),
                    child: Text(
                      _pretty(log.newData),
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Block
                  if (log.details != null && log.details!.isNotEmpty) ...[
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(200),
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        _pretty(log.details),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
