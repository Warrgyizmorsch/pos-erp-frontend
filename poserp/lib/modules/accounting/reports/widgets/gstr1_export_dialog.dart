import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../services/gstr1_export_service.dart';

class Gstr1ExportDialog extends StatelessWidget {
  final dynamic rawData;
  final String? gstin;
  final String? startDate;
  final String? endDate;

  const Gstr1ExportDialog({
    super.key,
    required this.rawData,
    this.gstin,
    this.startDate,
    this.endDate,
  });

  static Future<void> show(
    BuildContext context, {
    required dynamic rawData,
    String? gstin,
    String? startDate,
    String? endDate,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => Gstr1ExportDialog(
        rawData: rawData,
        gstin: gstin,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final payload = Gstr1ExportService.buildGstr1Payload(
      rawData,
      gstin: gstin,
      startDate: startDate,
      endDate: endDate,
    );

    final jsonString = Gstr1ExportService.formatGstr1Json(
      rawData,
      gstin: gstin,
      startDate: startDate,
      endDate: endDate,
    );

    final b2bCount = (payload['b2b'] as List?)?.length ?? 0;
    final b2csCount = (payload['b2cs'] as List?)?.length ?? 0;
    final hsnCount =
        ((payload['hsn'] as Map?)?['data'] as List?)?.length ?? 0;
    final period = payload['fp']?.toString() ?? '—';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.data_object_rounded,
                          color: Colors.indigo,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GSTR-1 Offline Tool JSON (GST3.0.0)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Filing Period: $period • Schema: GST3.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Metrics Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildChip('B2B Invoices: $b2bCount', AppColors.primary),
                  _buildChip('B2C Small: $b2csCount', AppColors.info),
                  _buildChip('HSN Codes: $hsnCount', Colors.teal),
                  _buildChip(
                    'GSTIN: ${payload['gstin']}',
                    Colors.deepPurple,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Code Preview Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputDark : Colors.grey[100],
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foregroundLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Compatible with GST Offline Tool v3.0+',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Close',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Copy JSON',
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () async {
                          await Gstr1ExportService.copyGstr1JsonToClipboard(
                            rawData,
                            gstin: gstin,
                            startDate: startDate,
                            endDate: endDate,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Save JSON',
                        icon: const Icon(Icons.download_rounded, size: 16),
                        variant: AppButtonVariant.primary,
                        onPressed: () async {
                          await Gstr1ExportService.copyGstr1JsonToClipboard(
                            rawData,
                            gstin: gstin,
                            startDate: startDate,
                            endDate: endDate,
                          );
                          Get.back();
                          AppSnackbar.success(
                            'GSTR-1 JSON (GST3.0.0) generated and ready for offline filing.',
                            title: 'Export Complete',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
