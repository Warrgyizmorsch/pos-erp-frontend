import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../products/models/product.dart';
import '../controllers/pos_controller.dart';
import 'camera_scanner_dialog.dart';

class POSItemTable extends StatefulWidget {
  const POSItemTable({super.key});

  @override
  State<POSItemTable> createState() => _POSItemTableState();
}

class _POSItemTableState extends State<POSItemTable> {
  final FocusNode _searchFocusNode = FocusNode();
  TextEditingController? _activeTextController;

  // Hardware barcode scanner buffer logic for HID scanners (< 50ms keystrokes)
  final StringBuffer _barcodeBuffer = StringBuffer();
  DateTime _lastKeyTime = DateTime.now();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleHardwareKeyScan(KeyEvent event) async {
    if (event is! KeyDownEvent) return;

    final controller = Get.find<POSController>();
    final now = DateTime.now();
    final delta = now.difference(_lastKeyTime).inMilliseconds;
    _lastKeyTime = now;

    // Enter Key completes scan
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final barcode = _barcodeBuffer.toString().trim();
      _barcodeBuffer.clear();

      if (barcode.isNotEmpty) {
        final success = await controller.onScanBarcode(barcode);
        if (success) {
          _activeTextController?.clear();
          _searchFocusNode.requestFocus();
        }
      }
      return;
    }

    // Capture printable character stream
    final char = event.character;
    if (char != null && char.isNotEmpty && char.codeUnitAt(0) >= 32) {
      if (delta > 50 && _barcodeBuffer.isNotEmpty) {
        // Slow typing reset (manual input)
        _barcodeBuffer.clear();
      }
      _barcodeBuffer.write(char);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: _searchFocusNode,
      onKeyEvent: _handleHardwareKeyScan,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barcode Scan / Autocomplete Field
            Autocomplete<Product>(
              displayStringForOption: (p) =>
                  '${p.name} (₹${p.salesPrice.toStringAsFixed(2)})',
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Product>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                return controller.availableProducts.where(
                  (p) =>
                      p.name.toLowerCase().contains(query) ||
                      p.sku.toLowerCase().contains(query) ||
                      (p.barcode != null &&
                          p.barcode!.toLowerCase().contains(query)),
                );
              },
              onSelected: (product) {
                controller.addItemFromProduct(product);
                _activeTextController?.clear();
                _searchFocusNode.requestFocus();
              },
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                    _activeTextController = textController;
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        if (value.trim().isEmpty) return;
                        final success = await controller.onScanBarcode(value);
                        if (success) {
                          textController.clear();
                          focusNode.requestFocus();
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Scan Barcode or Search Product by Name/SKU...',
                        prefixIcon: const Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.primary,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (textController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  textController.clear();
                                  setState(() {});
                                },
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              tooltip: 'Open Camera Barcode Scanner',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CameraScannerDialog(),
                                );
                              },
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.lg,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.lg,
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(height: 16),

            // Items List Table
            Expanded(
              child: Obx(() {
                final bill = controller.activeBill;
                if (bill == null) return const SizedBox.shrink();

                final items = bill.items;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? AppColors.cardDark : Colors.grey[100],
                      ),
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Item Name')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Rate (₹)')),
                        DataColumn(label: Text('Disc (%)')),
                        DataColumn(label: Text('Tax (%)')),
                        DataColumn(label: Text('Total (₹)')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final isPlaceholder = item.itemName.isEmpty;

                        if (isPlaceholder) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${idx + 1}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              const DataCell(
                                Text(
                                  'Search / Scan to add product...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const DataCell(Text('—')),
                              const DataCell(Text('—')),
                              const DataCell(Text('—')),
                              const DataCell(Text('—')),
                              const DataCell(Text('—')),
                              const DataCell(SizedBox.shrink()),
                            ],
                          );
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (item.itemCode.isNotEmpty)
                                    Text(
                                      item.itemCode,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForegroundLight,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Qty counter
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 18,
                                    ),
                                    onPressed: item.quantity > 1
                                        ? () => controller.updateItemQuantity(
                                            item.id,
                                            item.quantity - 1,
                                          )
                                        : null,
                                  ),
                                  Text(
                                    '${item.quantity.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        controller.updateItemQuantity(
                                          item.id,
                                          item.quantity + 1,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Rate
                            DataCell(
                              Text(item.pricePerUnit.toStringAsFixed(2)),
                            ),
                            // Disc
                            DataCell(
                              Text('${item.discount.toStringAsFixed(0)}%'),
                            ),
                            // Tax
                            DataCell(
                              Text('${item.taxPercent.toStringAsFixed(0)}%'),
                            ),
                            // Total
                            DataCell(
                              Text(
                                '₹${item.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            // Delete Item
                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                onPressed: () => controller.removeItem(item.id),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
