import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../data/services/bluetooth_printer_service.dart';

class BluetoothPrinterDialog extends StatelessWidget {
  const BluetoothPrinterDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final service = Get.find<BluetoothPrinterService>();
    // Auto scan when opening dialog if devices list is empty
    if (service.availableDevices.isEmpty) {
      service.scanDevices();
    }
    await showDialog(
      context: context,
      builder: (context) => const BluetoothPrinterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final printerService = Get.find<BluetoothPrinterService>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 650),
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
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.sm,
                        ),
                        child: const Icon(
                          Icons.print_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thermal Printer Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Connect Posiflow / ESC-POS Bluetooth printer',
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
              const SizedBox(height: 16),

              // Active Connection Status Card
              Obx(() {
                final isConn = printerService.isConnected.value;
                final devName = printerService.connectedPrinterName.value;
                final devMac = printerService.connectedPrinterMac.value;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isConn
                        ? AppColors.success.withAlpha(15)
                        : Colors.orange.withAlpha(15),
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: isConn
                          ? AppColors.success.withAlpha(80)
                          : Colors.orange.withAlpha(80),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isConn
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: isConn ? AppColors.success : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConn
                                      ? 'Connected to $devName'
                                      : 'No Printer Connected',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isConn
                                        ? AppColors.success
                                        : Colors.orange[800],
                                  ),
                                ),
                                if (isConn && devMac.isNotEmpty)
                                  Text(
                                    'MAC: $devMac',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (isConn) ...[
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.receipt, size: 14),
                              label: const Text('Test Print',
                                  style: TextStyle(fontSize: 11)),
                              onPressed: printerService.isPrinting.value
                                  ? null
                                  : () => printerService.printTestReceipt(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.link_off,
                                  size: 18, color: Colors.red),
                              tooltip: 'Disconnect',
                              onPressed: () => printerService.disconnect(),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Paper Width Preference Selector
              Row(
                children: [
                  const Text(
                    'Paper Width:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Obx(() {
                    final current = printerService.paperSize.value;
                    return Row(
                      children: [
                        ChoiceChip(
                          label: const Text('80mm (Standard POS)',
                              style: TextStyle(fontSize: 11)),
                          selected: current == '80mm',
                          onSelected: (sel) {
                            if (sel) printerService.setPaperSize('80mm');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('58mm (Mini)',
                              style: TextStyle(fontSize: 11)),
                          selected: current == '58mm',
                          onSelected: (sel) {
                            if (sel) printerService.setPaperSize('58mm');
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              // Available Devices Section Title & Scan Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Bluetooth Devices',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Obx(
                    () => TextButton.icon(
                      onPressed: printerService.isScanning.value
                          ? null
                          : () => printerService.scanDevices(),
                      icon: printerService.isScanning.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      label: Text(
                        printerService.isScanning.value
                            ? 'Scanning...'
                            : 'Scan',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),

              // Devices List
              Flexible(
                child: Obx(() {
                  final devices = printerService.availableDevices;
                  final isScanning = printerService.isScanning.value;
                  final isConn = printerService.isConnected.value;
                  final connMac = printerService.connectedPrinterMac.value;
                  final isConnecting = printerService.isConnecting.value;

                  if (isScanning && devices.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Searching for paired thermal printers...',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (devices.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.print_disabled,
                                size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            const Text(
                              'No paired Bluetooth printers found',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1. Turn ON your Posiflow printer.\n2. Open device Settings > Bluetooth and Pair it.\n3. Return here and tap Scan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              text: 'Scan Again',
                              icon: const Icon(Icons.refresh, size: 16),
                              variant: AppButtonVariant.outline,
                              onPressed: () => printerService.scanDevices(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: devices.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final isCurrent =
                          isConn && connMac == device.macAdress;

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? AppColors.success.withAlpha(30)
                                : Colors.grey.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.print,
                            size: 18,
                            color: isCurrent
                                ? AppColors.success
                                : Colors.grey[700],
                          ),
                        ),
                        title: Text(
                          device.name.isNotEmpty ? device.name : 'Unknown Device',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          device.macAdress,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        trailing: isCurrent
                            ? const Chip(
                                avatar: Icon(Icons.check,
                                    size: 14, color: Colors.white),
                                label: Text(
                                  'Connected',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: AppColors.success,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: isConnecting
                                    ? null
                                    : () => printerService.connect(
                                          device.macAdress,
                                          name: device.name,
                                        ),
                                child: const Text(
                                  'Connect',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Bottom note & close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Supports Posiflow, Sunmi, Xprinter & standard 58/80mm ESC-POS printers.',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                  AppButton(
                    text: 'Done',
                    variant: AppButtonVariant.primary,
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
