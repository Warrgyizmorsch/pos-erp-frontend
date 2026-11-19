import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/pos_controller.dart';

class CameraScannerDialog extends StatefulWidget {
  const CameraScannerDialog({super.key});

  @override
  State<CameraScannerDialog> createState() => _CameraScannerDialogState();
}

class _CameraScannerDialogState extends State<CameraScannerDialog> {
  final POSController controller = Get.find<POSController>();
  final MobileScannerController _cameraController = MobileScannerController();
  final TextEditingController manualBarcodeCtrl = TextEditingController();

  bool isContinuousScanning = true;
  bool isProcessing = false;
  bool isTorchOn = false;

  @override
  void dispose() {
    _cameraController.dispose();
    manualBarcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _processBarcode(String barcode) async {
    if (isProcessing || barcode.trim().isEmpty) return;

    setState(() => isProcessing = true);
    final success = await controller.onScanBarcode(barcode.trim());

    if (mounted) {
      setState(() => isProcessing = false);
      if (success && !isContinuousScanning) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Camera Barcode Scanner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isTorchOn ? Icons.flash_on : Icons.flash_off,
                      size: 20,
                      color: isTorchOn ? Colors.amber : Colors.grey,
                    ),
                    tooltip: 'Toggle Flashlight',
                    onPressed: () {
                      _cameraController.toggleTorch();
                      setState(() => isTorchOn = !isTorchOn);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Mobile Camera Stream & Target Frame Overlay
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputDark : Colors.grey[900],
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.primary.withAlpha(80)),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.md,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Live Camera Stream
                      MobileScanner(
                        controller: _cameraController,
                        onDetect: (capture) {
                          if (isProcessing) return;
                          final barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty &&
                              barcodes.first.rawValue != null) {
                            final code = barcodes.first.rawValue!;
                            _processBarcode(code);
                          }
                        },
                        errorBuilder: (context, error, child) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_rear_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Camera Preview Unavailable',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Use Handheld Scanner or Manual Input below',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Target Red Laser Viewfinder Overlay
                      Container(
                        width: 260,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isProcessing
                                ? AppColors.success
                                : AppColors.danger,
                            width: 2,
                          ),
                          borderRadius: AppRadius.md,
                        ),
                      ),

                      // Laser Line Indicator
                      Container(
                        width: 240,
                        height: 2,
                        color: isProcessing
                            ? AppColors.success
                            : AppColors.danger.withAlpha(200),
                      ),

                      // Status Overlay Banner
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: AppRadius.full,
                          ),
                          child: Text(
                            isProcessing
                                ? 'Processing Code...'
                                : 'Align barcode inside red laser frame',
                            style: TextStyle(
                              fontSize: 11,
                              color: isProcessing
                                  ? AppColors.success
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continuous Scanning Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Continuous Batch Scan Mode',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: isContinuousScanning,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => isContinuousScanning = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Manual Input / Handheld Scanner Trigger Field
              const Text(
                'MANUAL / HANDHELD BARCODE INPUT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: manualBarcodeCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter barcode string...',
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
                      onSubmitted: (val) {
                        _processBarcode(val);
                        manualBarcodeCtrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Scan',
                    icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                    variant: AppButtonVariant.primary,
                    isLoading: isProcessing,
                    onPressed: () {
                      _processBarcode(manualBarcodeCtrl.text);
                      manualBarcodeCtrl.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close Scanner',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
