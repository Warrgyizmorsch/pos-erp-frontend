import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/subcategory_controller.dart';
import '../models/subcategory.dart';

class SubcategoryDialog extends StatefulWidget {
  final Subcategory? subcategory;

  const SubcategoryDialog({super.key, this.subcategory});

  @override
  State<SubcategoryDialog> createState() => _SubcategoryDialogState();
}

class _SubcategoryDialogState extends State<SubcategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  String? _selectedParentCategoryId;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<SubcategoryController>();

    _nameController = TextEditingController(
      text: widget.subcategory?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.subcategory?.description ?? '',
    );
    _imageController = TextEditingController(
      text: widget.subcategory?.image ?? '',
    );

    _selectedParentCategoryId = widget.subcategory?.parentCategoryIdString;
    if (_selectedParentCategoryId == null && controller.categories.isNotEmpty) {
      _selectedParentCategoryId = controller.categories.first.id;
    }

    _isActive = widget.subcategory?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_selectedParentCategoryId == null ||
        _selectedParentCategoryId!.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a Parent Category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<SubcategoryController>();
      final success = await controller.saveSubcategory(
        editSubcategory: widget.subcategory,
        name: _nameController.text.trim(),
        parentCategoryId: _selectedParentCategoryId!,
        description: _descriptionController.text.trim(),
        image: _imageController.text.trim().isNotEmpty
            ? _imageController.text.trim()
            : null,
        isActive: _isActive,
      );
      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SubcategoryController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.subcategory != null
                        ? 'Edit Subcategory'
                        : 'Add New Subcategory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foregroundLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Add details for this subcategory and assign it to a main category.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForegroundLight,
                ),
              ),
              const SizedBox(height: 20),
              // Parent Category Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Main Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foregroundLight,
                      ),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() {
                    final availableCategoryIds = controller.categories
                        .map((c) => c.id)
                        .toSet();
                    final validValue =
                        availableCategoryIds.contains(_selectedParentCategoryId)
                        ? _selectedParentCategoryId
                        : (controller.categories.isNotEmpty
                              ? controller.categories.first.id
                              : null);

                    return DropdownButtonFormField<String>(
                      initialValue: validValue,
                      hint: const Text('Select Parent Category'),
                      dropdownColor: isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
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
                      items: controller.categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foregroundLight,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedParentCategoryId = val),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              // Subcategory Name Input
              AppTextField(
                label: 'Subcategory Name',
                hintText: 'e.g. Mobile Phones',
                controller: _nameController,
                validator: (val) =>
                    Validators.required(val, fieldName: 'Subcategory name'),
                isRequired: true,
              ),
              const SizedBox(height: 16),
              // Image URL Input
              AppTextField(
                label: 'Image URL (optional)',
                hintText: 'https://example.com/image.png',
                controller: _imageController,
              ),
              const SizedBox(height: 16),
              // Description Input
              AppTextField(
                label: 'Description (optional)',
                hintText: 'Brief description...',
                controller: _descriptionController,
              ),
              const SizedBox(height: 16),
              // Active Status Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foregroundLight,
                        ),
                      ),
                      Text(
                        'Visible in POS and product catalog',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForegroundLight,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isActive,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => AppButton(
                      text: widget.subcategory != null
                          ? 'Update Subcategory'
                          : 'Create Subcategory',
                      isLoading: controller.isSaving.value,
                      onPressed: _onSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
