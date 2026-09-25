import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GSTR-1 Offline Tool JSON',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Period: $period • Schema: GST3.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metrics Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildChip('B2B: $b2bCount', AppColors.primary),
                  _buildChip('B2C: $b2csCount', AppColors.info),
                  _buildChip('HSN: $hsnCount', Colors.teal),
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
                        fontSize: 11,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foregroundLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 460;
                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Compatible with GST Offline Tool v3.0+',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Close',
                                variant: AppButtonVariant.outline,
                                height: AppSizes.buttonHeightSm,
                                onPressed: () => Get.back(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                text: 'Copy JSON',
                                icon: const Icon(Icons.copy_rounded, size: 15),
                                variant: AppButtonVariant.primary,
                                height: AppSizes.buttonHeightSm,
                                onPressed: () async {
                                  await Gstr1ExportService.copyGstr1JsonToClipboard(
                                    rawData,
                                    gstin: gstin,
                                    startDate: startDate,
                                    endDate: endDate,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
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
                            height: AppSizes.buttonHeightSm,
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Copy JSON',
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            variant: AppButtonVariant.outline,
                            height: AppSizes.buttonHeightSm,
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
                            height: AppSizes.buttonHeightSm,
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
