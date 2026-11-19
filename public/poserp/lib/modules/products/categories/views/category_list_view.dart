import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
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
    return Scaffold(
      appBar: AppTopBar(
        title: 'Product Categories',
        subtitle: 'Organize catalog items & images',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            tooltip: 'Add Category',
            onPressed: _openCreateDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchCategories(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              AppCard(
                padding: const EdgeInsets.all(12),
                child: AppSearchField(
                  hintText: 'Search categories by name...',
                  onChanged: (val) => controller.search.value = val,
                ),
              ),
              const SizedBox(height: 16),

              // Categories List Section
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(message: 'Loading categories...'),
                  );
                }

                if (controller.categories.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      title: 'No categories found',
                      description: controller.search.value.isNotEmpty
                          ? 'Try searching with a different keyword.'
                          : 'Create your first product category.',
                      icon: Icons.category_outlined,
                      action: controller.search.value.isEmpty
                          ? AppButton(
                              text: 'Add Category',
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
                      itemCount: controller.categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final cat = controller.categories[index];

                        return AppListCard(
                          title: cat.name,
                          subtitle: 'ID: ${cat.customId ?? "CAT-${index + 1}"}',
                          trailingText: '${cat.productCount} Items',
                          statusText: cat.isActive ? 'ACTIVE' : 'INACTIVE',
                          statusType: cat.isActive
                              ? AppStatusChipType.success
                              : AppStatusChipType.warning,
                          leadIcon: Icons.folder_open_rounded,
                          onTap: () => _openEditDialog(cat),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openEditDialog(cat);
                              } else if (val == 'delete') {
                                _confirmDelete(cat);
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
                                    Text('Edit Category'),
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
                                    Text('Delete Category'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
    );
  }
}
