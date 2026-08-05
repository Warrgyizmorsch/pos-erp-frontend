import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/opening_stock_controller.dart';

class OpeningStockView extends GetView<OpeningStockController> {
  const OpeningStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opening Stock Entry'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record opening stock of inventory and set initial stock levels',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 20),

            // Top Details Card (Date, Notes & Global Tax Type)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => AppTextField(
                            label: 'Opening Stock Date',
                            hintText: 'YYYY-MM-DD',
                            initialValue: controller.openingStockDate.value,
                            onChanged: (val) =>
                                controller.openingStockDate.value = val,
                            isRequired: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Global Purchase Tax Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foregroundLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(
                              () => DropdownButtonFormField<String>(
                                initialValue: controller.globalTaxType.value,
                                dropdownColor: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.lg,
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? AppColors.inputDark
                                          : AppColors.inputLight,
                                    ),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'without',
                                    child: Text('Without Tax (Exclusive)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'with',
                                    child: Text('With Tax (Inclusive)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.setGlobalTaxType(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Notes (optional)',
                    hintText:
                        'Additional remarks about this opening stock entry...',
                    onChanged: (val) => controller.notes.value = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Items List Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stock Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foregroundLight,
                  ),
                ),
                AppButton(
                  text: 'Add Row',
                  icon: const Icon(Icons.add, size: 18),
                  height: 36,
                  variant: AppButtonVariant.outline,
                  onPressed: () => controller.addItem(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item Rows List
            Obx(() {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.items[index];

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product Selector / Autocomplete
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: item.product?.id,
                                hint: const Text(
                                  'Select or search existing product...',
                                ),
                                dropdownColor: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.lg,
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? AppColors.inputDark
                                          : AppColors.inputLight,
                                    ),
                                  ),
                                ),
                                items: controller.availableProducts
                                    .map(
                                      (p) => DropdownMenuItem<String>(
                                        value: p.id,
                                        child: Text(
                                          '${p.name} (${p.sku})',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? AppColors.foregroundDark
                                                : AppColors.foregroundLight,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final selectedProd = controller
                                        .availableProducts
                                        .firstWhereOrNull((p) => p.id == val);
                                    if (selectedProd != null) {
                                      controller.selectProduct(
                                        index,
                                        selectedProd,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            if (controller.items.length > 1) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                color: AppColors.danger,
                                onPressed: () => controller.removeItem(index),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Or Enter Custom / New Product Name
                        if (item.product == null) ...[
                          AppTextField(
                            label: 'New Product Name (if not in catalog)',
                            hintText: 'e.g. Fresh Milk 1L',
                            initialValue: item.newProductName,
                            onChanged: (val) {
                              item.newProductName = val;
                              controller.items.refresh();
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Inputs: Quantity, Unit, Purchase Rate, Sales Price, Tax Rate
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Qty',
                                hintText: '1',
                                initialValue: item.quantity.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item.quantity = double.tryParse(val) ?? 1;
                                  controller.items.refresh();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foregroundLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    initialValue: item.unit,
                                    dropdownColor: isDark
                                        ? AppColors.cardDark
                                        : AppColors.cardLight,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 10,
                                          ),
                                      filled: true,
                                      fillColor: isDark
                                          ? AppColors.cardDark
                                          : AppColors.cardLight,
                                      border: OutlineInputBorder(
                                        borderRadius: AppRadius.lg,
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.inputDark
                                              : AppColors.inputLight,
                                        ),
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'piece',
                                        child: Text('Piece'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'box',
                                        child: Text('Box'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'kg',
                                        child: Text('Kg'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'liter',
                                        child: Text('Liter'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'meter',
                                        child: Text('Meter'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'dozen',
                                        child: Text('Dozen'),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        item.unit = val;
                                        controller.items.refresh();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                label: 'Purchase Rate',
                                hintText: '0.00',
                                initialValue: item.purchaseRate.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item.purchaseRate = double.tryParse(val) ?? 0;
                                  controller.items.refresh();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppTextField(
                                label: 'Sales Price',
                                hintText: '0.00',
                                initialValue: item.salesPrice.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item.salesPrice = double.tryParse(val) ?? 0;
                                  controller.items.refresh();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Valuation: ₹${item.valuation.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 24),

            // Summary Card
            Obx(
              () => AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForegroundLight,
                          ),
                        ),
                        Text(
                          '${controller.totalItems}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foregroundLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity:',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForegroundLight,
                          ),
                        ),
                        Text(
                          controller.totalQuantity.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foregroundLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Stock Valuation:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foregroundLight,
                          ),
                        ),
                        Text(
                          '₹${controller.totalValuation.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: 'Save Opening Stock',
                      width: double.infinity,
                      height: 44,
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final ok = await controller.submit();
                        if (ok) {
                          Get.back();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
