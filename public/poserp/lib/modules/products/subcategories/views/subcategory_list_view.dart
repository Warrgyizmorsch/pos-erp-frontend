import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
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
      appBar: AppTopBar(
        title: 'Subcategories',
        subtitle: 'Manage sub-groupings & parent categories',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            tooltip: 'Add Subcategory',
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
              // Search & Parent Category Filter
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText: 'Search subcategories...',
                      onChanged: (val) => controller.search.value = val,
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
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
                            child: Text('All Parent Categories'),
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
                            controller.selectedParentCategoryId.value = val;
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Data List Section
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
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
                      itemCount: controller.subcategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final subcat = controller.subcategories[index];

                        return AppListCard(
                          title: subcat.name,
                          subtitle:
                              'Parent: ${subcat.parentCategoryName} • ID: ${subcat.customId ?? "SUBCAT-${index + 1}"}',
                          trailingText: '${subcat.productCount} Items',
                          statusText: subcat.isActive ? 'ACTIVE' : 'INACTIVE',
                          statusType: subcat.isActive
                              ? AppStatusChipType.success
                              : AppStatusChipType.warning,
                          leadIcon: Icons.account_tree_outlined,
                          onTap: () => _openEditDialog(subcat),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openEditDialog(subcat);
                              } else if (val == 'delete') {
                                _confirmDelete(subcat);
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
                                    Text('Edit Subcategory'),
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
                                    Text('Delete Subcategory'),
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
