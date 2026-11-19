import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_list_card.dart';
import '../../../core/widgets/app_pagination.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/app_status_chip.dart';
import '../../../core/widgets/app_top_bar.dart';
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
      appBar: AppTopBar(
        title: 'Products Catalog',
        subtitle: 'Manage items, pricing & stock thresholds',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            tooltip: 'Add Product',
            onPressed: _openCreateDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mobile Filter & Search Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText: 'Search by product name, SKU or barcode...',
                      onChanged: (val) => controller.search.value = val,
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
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
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'all',
                            child: Text('All Product Categories'),
                          ),
                          ...controller.categories.map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.name),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
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
                          ? 'Try clearing your search query or category filter.'
                          : 'Add your first product to start cataloging.',
                      icon: Icons.inventory_2_outlined,
                      action:
                          controller.search.value.isEmpty &&
                              controller.selectedCategoryFilter.value == 'all'
                          ? AppButton(
                              text: 'Add First Product',
                              icon: const Icon(Icons.add_rounded, size: 18),
                              onPressed: _openCreateDialog,
                            )
                          : null,
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.products.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        final isOut = product.stock <= 0;
                        final isLow =
                            product.stock > 0 &&
                            product.stock <= product.lowStockThreshold;

                        AppStatusChipType chipType = AppStatusChipType.success;
                        String stockStatus =
                            '${product.stock.toStringAsFixed(0)} ${product.unit.toUpperCase()}';

                        if (isOut) {
                          chipType = AppStatusChipType.danger;
                          stockStatus = 'OUT OF STOCK';
                        } else if (isLow) {
                          chipType = AppStatusChipType.warning;
                          stockStatus =
                              'LOW (${product.stock.toStringAsFixed(0)} ${product.unit.toUpperCase()})';
                        }

                        return AppListCard(
                          title: product.name,
                          subtitle:
                              'SKU: ${product.sku} • ${product.categoryName}',
                          trailingText:
                              '₹${product.salesPrice.toStringAsFixed(2)}',
                          statusText: stockStatus,
                          statusType: chipType,
                          leadIcon: Icons.inventory_2_outlined,
                          onTap: () => _openEditDialog(product),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openEditDialog(product);
                              } else if (val == 'delete') {
                                _confirmDelete(product);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit Item Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.danger,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Delete Item'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pagination Control
                    AppPagination(
                      currentPage: controller.currentPage.value,
                      totalPages: controller.totalPages.value,
                      onPageChanged: (p) => controller.changePage(p),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'product_add_fab',
        onPressed: _openCreateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
