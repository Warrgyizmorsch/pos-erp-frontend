import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/purchase_controller.dart';

class PurchaseDetailView extends GetView<PurchaseController> {
  const PurchaseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String? purchaseId = Get.parameters['id'];
    final horizontalScrollController = ScrollController();

    if (purchaseId != null &&
        (controller.selectedPurchase.value == null ||
            controller.selectedPurchase.value!.id != purchaseId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadPurchaseDetails(purchaseId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Details'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Obx(() {
            final purchase = controller.selectedPurchase.value;
            if (purchase == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: AppButton(
                text: 'Edit Bill',
                icon: const Icon(Icons.edit, size: 18),
                height: 36,
                onPressed: () {
                  controller.initEditForm(purchase);
                  Get.toNamed('/purchases/create?id=${purchase.id}');
                },
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(
            message: 'Loading purchase bill details...',
          );
        }

        final purchase = controller.selectedPurchase.value;
        if (purchase == null) {
          return const Center(child: Text('Purchase Bill Not Found'));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.purchaseNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created Date: ${purchase.purchaseDate.split('T')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: AppRadius.sm,
                          ),
                          child: Text(
                            purchase.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (purchase.paymentStatus == 'paid'
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withValues(alpha: 0.15),
                            borderRadius: AppRadius.sm,
                          ),
                          child: Text(
                            purchase.paymentStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: purchase.paymentStatus == 'paid'
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Supplier & Purchase Info Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUPPLIER DETAILS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            purchase.supplierName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (purchase.supplierPhone != null)
                            Text(
                              'Phone: ${purchase.supplierPhone}',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (purchase.supplierGst != null)
                            Text(
                              'GSTIN: ${purchase.supplierGst}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BILL SUMMARY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (purchase.invoiceNumber != null &&
                              purchase.invoiceNumber!.isNotEmpty)
                            Text(
                              'Ref: ${purchase.invoiceNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            'Mode: ${purchase.paymentMethod.toUpperCase()}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Supply: ${purchase.stateOfSupply ?? 'Rajasthan'}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Items Table Card
              AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
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
                          isDark ? AppColors.cardDark : Colors.grey[100],
                        ),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Item Name')),
                          DataColumn(label: Text('SKU / Barcode')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Purchase Rate (₹)')),
                          DataColumn(label: Text('Sales Price (₹)')),
                          DataColumn(label: Text('Tax %')),
                          DataColumn(label: Text('Line Total (₹)')),
                        ],
                        rows: purchase.items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(Text('${idx + 1}')),
                              DataCell(
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  item.sku ?? item.barcode ?? '-',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(Text('${item.quantity.toInt()}')),
                              DataCell(
                                Text(
                                  '₹${item.purchasePrice.toStringAsFixed(2)}',
                                ),
                              ),
                              DataCell(
                                Text('₹${item.salesPrice.toStringAsFixed(2)}'),
                              ),
                              DataCell(Text('${item.taxRate}%')),
                              DataCell(
                                Text(
                                  '₹${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Totals Breakdown
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 13)),
                        Text(
                          '₹${purchase.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (purchase.discountAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discount:',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            '-₹${purchase.discountAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    if (purchase.shippingCharges > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shipping Charges:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            '+₹${purchase.shippingCharges.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    if (purchase.taxAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'GST Tax:',
                            style: TextStyle(fontSize: 13),
                          ),
                          Text(
                            '+₹${purchase.taxAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${purchase.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Amount Paid:',
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          '₹${purchase.amountPaid.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    if (purchase.dueAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Due Amount:',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.danger,
                            ),
                          ),
                          Text(
                            '₹${purchase.dueAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
