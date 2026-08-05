import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';
import '../widgets/category_dialog.dart';

class CategoryListView extends GetView<CategoryController> {
  const CategoryListView({super.key});

  void _openCreateDialog() {
    Get.dialog(const CategoryDialog());
  }

  void _openEditDialog(Category category) {
    Get.dialog(CategoryDialog(category: category));
  }

  void _confirmDelete(Category category) {
    Get.dialog(
      ConfirmDialog(
        title: 'Delete Category',
        description:
            'Are you sure you want to delete "${category.name}"? This action will hide the category from POS.',
        confirmLabel: 'Delete Category',
        isDestructive: true,
        onConfirm: () async {
          Get.back();
          await controller.deleteCategory(category.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Category',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: _openCreateDialog,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchCategories(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Sub-header
              Text(
                'Manage product categories and images',
                style: AppTypography.caption(isDark: isDark),
              ),
              const SizedBox(height: 20),
              // Search Control Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hintText: 'Search categories...',
                        onChanged: (val) => controller.search.value = val,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Main Data Section
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: LoadingIndicator(message: 'Loading categories...'),
                  );
                }

                if (controller.categories.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      title: 'No categories found',
                      description: controller.search.value.isNotEmpty
                          ? 'Try a different search term.'
                          : 'Create your first category to organize products.',
                      icon: Icons.label_outline,
                      action: controller.search.value.isEmpty
                          ? AppButton(
                              text: 'Add Category',
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
                      // Table Header & Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.categories.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final cat = controller.categories[index];
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
                              child: cat.image != null && cat.image!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: AppRadius.md,
                                      child: Image.network(
                                        cat.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 20,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foregroundLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cat.isActive
                                        ? AppColors.success.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    cat.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cat.isActive
                                          ? AppColors.success
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              cat.customId ?? 'CAT-${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForegroundLight,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${cat.productCount} items',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  color: AppColors.primary,
                                  tooltip: 'Edit Category',
                                  onPressed: () => _openEditDialog(cat),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.danger,
                                  tooltip: 'Delete Category',
                                  onPressed: () => _confirmDelete(cat),
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
