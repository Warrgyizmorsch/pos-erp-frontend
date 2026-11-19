import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../controllers/opening_stock_controller.dart';

class OpeningStockView extends GetView<OpeningStockController> {
  const OpeningStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Opening Stock Entry',
        subtitle: 'Record initial inventory quantities & valuations',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Details Card (Date & Tax Type)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Obx(
                    () => AppTextField(
                      label: 'Opening Stock Date',
                      hintText: 'YYYY-MM-DD',
                      initialValue: controller.openingStockDate.value,
                      onChanged: (val) =>
                          controller.openingStockDate.value = val,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
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
                          isExpanded: true,
                          initialValue: controller.globalTaxType.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
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
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Remarks / Notes (optional)',
                    hintText: 'e.g. FY 2026-27 Initial Warehouse Audit',
                    onChanged: (val) => controller.notes.value = val,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items List Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Items Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                AppButton(
                  text: 'Add Product Row',
                  icon: const Icon(Icons.add_rounded, size: 16),
                  height: 38,
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
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withAlpha(25),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: item.product?.id,
                                hint: const Text(
                                  'Select catalog product...',
                                  style: TextStyle(fontSize: 13),
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
                                          style: const TextStyle(fontSize: 13),
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
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                color: AppColors.danger,
                                onPressed: () => controller.removeItem(index),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (item.product == null) ...[
                          AppTextField(
                            label: 'New Product Name (if not in catalog)',
                            hintText: 'e.g. Organic Almond Milk 1L',
                            initialValue: item.newProductName,
                            onChanged: (val) {
                              item.newProductName = val;
                              controller.items.refresh();
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
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
            const SizedBox(height: 20),

            // Summary Card & Sticky Submit
            Obx(
              () => AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Items Logged:',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          '${controller.totalItems}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Quantity:',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          controller.totalQuantity.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Stock Valuation:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Save Opening Stock',
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      width: double.infinity,
                      height: AppSizes.buttonHeightMd,
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
