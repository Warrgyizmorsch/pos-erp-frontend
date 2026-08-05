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
import '../controllers/subcategory_controller.dart';
import '../models/subcategory.dart';
import '../widgets/subcategory_dialog.dart';

class SubcategoryListView extends GetView<SubcategoryController> {
  const SubcategoryListView({super.key});

  void _openCreateDialog() {
    Get.dialog(const SubcategoryDialog());
  }

  void _openEditDialog(Subcategory subcategory) {
    Get.dialog(SubcategoryDialog(subcategory: subcategory));
  }

  void _confirmDelete(Subcategory subcategory) {
    Get.dialog(
      ConfirmDialog(
        title: 'Delete Subcategory',
        description:
            'Are you sure you want to delete "${subcategory.name}"? This action will hide the subcategory.',
        confirmLabel: 'Delete Subcategory',
        isDestructive: true,
        onConfirm: () async {
          Get.back();
          await controller.deleteSubcategory(subcategory.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subcategories'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Subcategory',
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
                'Manage product subcategories and hierarchies',
                style: AppTypography.caption(isDark: isDark),
              ),
              const SizedBox(height: 20),
              // Search and Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppSearchField(
                        hintText: 'Search subcategories...',
                        onChanged: (val) => controller.search.value = val,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        final selectedId =
                            controller.selectedParentCategoryId.value;
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
                              controller.selectedParentCategoryId.value = val;
                            }
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Main Data Table
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: LoadingIndicator(
                      message: 'Loading subcategories...',
                    ),
                  );
                }

                if (controller.subcategories.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      title: 'No subcategories found',
                      description:
                          controller.search.value.isNotEmpty ||
                              controller.selectedParentCategoryId.value != 'all'
                          ? 'Try clearing your search or filter.'
                          : 'Create your first subcategory.',
                      icon: Icons.layers_outlined,
                      action:
                          controller.search.value.isEmpty &&
                              controller.selectedParentCategoryId.value == 'all'
                          ? AppButton(
                              text: 'Add Subcategory',
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
                        itemCount: controller.subcategories.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final subcat = controller.subcategories[index];
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
                                  subcat.image != null &&
                                      subcat.image!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: AppRadius.md,
                                      child: Image.network(
                                        subcat.image!,
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
                                      Icons.layers_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  subcat.name,
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
                                    color: subcat.isActive
                                        ? AppColors.success.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    subcat.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: subcat.isActive
                                          ? AppColors.success
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  subcat.customId ?? 'SUBCAT-${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForegroundLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.secondaryDark
                                        : AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Text(
                                    subcat.parentCategoryName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foregroundLight,
                                    ),
                                  ),
                                ),
                              ],
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
                                    '${subcat.productCount} items',
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
                                  tooltip: 'Edit Subcategory',
                                  onPressed: () => _openEditDialog(subcat),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: AppColors.danger,
                                  tooltip: 'Delete Subcategory',
                                  onPressed: () => _confirmDelete(subcat),
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
