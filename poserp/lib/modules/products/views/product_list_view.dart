import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_pagination.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../widgets/product_dialog.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  void _openCreateDialog() {
    Get.dialog(const ProductDialog());
  }

  void _openEditDialog(Product product) {
    Get.dialog(ProductDialog(product: product));
  }

  void _confirmDelete(Product product) {
    Get.dialog(
      ConfirmDialog(
        title: 'Delete Product',
        description:
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        confirmLabel: 'Delete Product',
        isDestructive: true,
        onConfirm: () async {
          Get.back();
          await controller.deleteProduct(product.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Catalog'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Product',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: _openCreateDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage your complete product inventory and catalog',
                style: AppTypography.caption(isDark: isDark),
              ),
              const SizedBox(height: 20),

              // Search & Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppSearchField(
                        hintText: 'Search products by name, SKU...',
                        onChanged: (val) => controller.search.value = val,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        final selectedId =
                            controller.selectedCategoryFilter.value;
                        final validIds = {
                          'all',
                          ...controller.categories.map((c) => c.id),
                        };
                        final validValue = validIds.contains(selectedId)
                            ? selectedId
                            : 'all';

                        return DropdownButtonFormField<String>(
                          initialValue: validValue,
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
                          items: [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Text(
                                'All Categories',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foregroundLight,
                                ),
                              ),
                            ),
                            ...controller.categories.map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(
                                  c.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foregroundLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedCategoryFilter.value = val;
                            }
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: LoadingIndicator(message: 'Loading products...'),
                  );
                }

                if (controller.products.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      title: 'No products found',
                      description:
                          controller.search.value.isNotEmpty ||
                              controller.selectedCategoryFilter.value != 'all'
                          ? 'Try clearing your search or filter.'
                          : 'Add your first product to get started.',
                      icon: Icons.inventory_2_outlined,
                      action:
                          controller.search.value.isEmpty &&
                              controller.selectedCategoryFilter.value == 'all'
                          ? AppButton(
                              text: 'Add Product',
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _openCreateDialog,
                            )
                          : null,
                    ),
                  );
                }

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.products.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final product = controller.products[index];

                          final isOut = product.stock <= 0;
                          final isLow =
                              product.stock > 0 &&
                              product.stock <= product.lowStockThreshold;

                          Color stockColor = AppColors.success;
                          if (isOut) stockColor = AppColors.danger;
                          if (isLow) stockColor = AppColors.warning;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.secondaryDark
                                    : AppColors.secondaryLight,
                                borderRadius: AppRadius.md,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child:
                                  product.image != null &&
                                      product.image!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: AppRadius.md,
                                      child: Image.network(
                                        product.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.inventory_2_outlined,
                                                  size: 20,
                                                ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.inventory_2_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foregroundLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${product.stock.toStringAsFixed(0)} ${product.unit}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: stockColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  'SKU: ${product.sku}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForegroundLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${product.categoryName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForegroundLight,
                                  ),
                                ),
                                if (product.subcategoryIdString != null) ...[
                                  Text(
                                    ' / ${product.subcategoryName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.mutedForegroundDark
                                          : AppColors.mutedForegroundLight,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${product.salesPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foregroundLight,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  color: AppColors.primary,
                                  tooltip: 'Edit Product',
                                  onPressed: () => _openEditDialog(product),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.danger,
                                  tooltip: 'Delete Product',
                                  onPressed: () => _confirmDelete(product),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Pagination
                      AppPagination(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPageChanged: (p) => controller.changePage(p),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
