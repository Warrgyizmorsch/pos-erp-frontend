import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;

  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _hsnCodeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;

  late final TextEditingController _salesPriceController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _taxRateController;

  late final TextEditingController _stockController;
  late final TextEditingController _lowStockThresholdController;
  late final TextEditingController _openingStockPriceController;

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String _selectedUnit = 'piece';
  String _salesTaxType = 'without';
  String _purchaseTaxType = 'without';

  final List<String> _unitOptions = [
    'piece',
    'kg',
    'liter',
    'meter',
    'box',
    'dozen',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final controller = Get.find<ProductController>();

    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(
      text: p?.sku ?? 'SKU-${1000 + Random().nextInt(9000)}',
    );
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _hsnCodeController = TextEditingController(text: p?.hsnCode ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _imageController = TextEditingController(
      text: p?.image ?? (p?.images.isNotEmpty == true ? p!.images.first : ''),
    );

    _salesPriceController = TextEditingController(
      text: p != null ? p.salesPrice.toString() : '0',
    );
    _purchasePriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toString() : '0',
    );
    _taxRateController = TextEditingController(
      text: p != null ? p.taxRate.toString() : '0',
    );

    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '0',
    );
    _lowStockThresholdController = TextEditingController(
      text: p != null ? p.lowStockThreshold.toString() : '10',
    );
    _openingStockPriceController = TextEditingController(
      text: p != null ? p.openingStockPrice.toString() : '0',
    );

    _selectedCategoryId = p?.categoryIdString;
    if ((_selectedCategoryId == null || _selectedCategoryId!.isEmpty) &&
        controller.categories.isNotEmpty) {
      _selectedCategoryId = controller.categories.first.id;
    }

    _selectedSubcategoryId = p?.subcategoryIdString;
    if (p != null) {
      _selectedUnit = p.unit;
      _salesTaxType = p.salesTaxType;
      _purchaseTaxType = p.purchaseTaxType;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _hsnCodeController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _salesPriceController.dispose();
    _purchasePriceController.dispose();
    _taxRateController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    _openingStockPriceController.dispose();
    super.dispose();
  }

  void _generateSKU() {
    final random = 1000 + Random().nextInt(9000);
    _skuController.text = 'SKU-$random';
  }

  void _generateBarcode() {
    final random = 100000000000 + Random().nextInt(900000000000);
    _barcodeController.text = random.toString();
  }

  void _onSave() async {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a Category',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final controller = Get.find<ProductController>();
      final img = _imageController.text.trim();

      final success = await controller.saveProduct(
        editProduct: widget.product,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().toUpperCase(),
        barcode: _barcodeController.text.trim().isNotEmpty
            ? _barcodeController.text.trim()
            : null,
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        subcategoryId: _selectedSubcategoryId,
        stock: double.tryParse(_stockController.text) ?? 0,
        lowStockThreshold:
            double.tryParse(_lowStockThresholdController.text) ?? 10,
        unit: _selectedUnit,
        images: img.isNotEmpty ? [img] : [],
        hsnCode: _hsnCodeController.text.trim(),
        salesPrice: double.tryParse(_salesPriceController.text) ?? 0,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        taxRate: double.tryParse(_taxRateController.text) ?? 0,
        salesTaxType: _salesTaxType,
        purchaseTaxType: _purchaseTaxType,
        openingStockPrice:
            double.tryParse(_openingStockPriceController.text) ?? 0,
        openingStockDate: DateTime.now().toIso8601String().split('T')[0],
      );

      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<ProductController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product != null ? 'Edit Item' : 'Add Item',
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
                'Manage product details, pricing and inventory levels',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForegroundLight,
                ),
              ),
              const SizedBox(height: 16),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForegroundLight,
                tabs: const [
                  Tab(text: 'DETAILS'),
                  Tab(text: 'PRICING'),
                  Tab(text: 'STOCK'),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Body
              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Details
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Item Name',
                                  hintText: 'e.g. White Bread',
                                  controller: _nameController,
                                  validator: (val) => Validators.required(
                                    val,
                                    fieldName: 'Item name',
                                  ),
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'HSN Code',
                                  hintText: 'HSN Code',
                                  controller: _hsnCodeController,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Category Dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category *',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foregroundLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final catIds = controller.categories
                                          .map((c) => c.id)
                                          .toSet();
                                      final validVal =
                                          catIds.contains(_selectedCategoryId)
                                          ? _selectedCategoryId
                                          : (controller.categories.isNotEmpty
                                                ? controller.categories.first.id
                                                : null);

                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        initialValue: validVal,
                                        dropdownColor: isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                        items: controller.categories
                                            .map(
                                              (c) => DropdownMenuItem<String>(
                                                value: c.id,
                                                child: Text(c.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(() {
                                          _selectedCategoryId = val;
                                          _selectedSubcategoryId = null;
                                        }),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Subcategory Dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subcategory',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foregroundLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final filteredSubcats = controller
                                          .subcategories
                                          .where(
                                            (s) =>
                                                s.parentCategoryIdString ==
                                                _selectedCategoryId,
                                          )
                                          .toList();

                                      final subcatIds = filteredSubcats
                                          .map((s) => s.id)
                                          .toSet();
                                      final validSubVal =
                                          subcatIds.contains(
                                            _selectedSubcategoryId,
                                          )
                                          ? _selectedSubcategoryId
                                          : null;

                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        initialValue: validSubVal,
                                        hint: const Text('None'),
                                        dropdownColor: isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('None'),
                                          ),
                                          ...filteredSubcats.map(
                                            (s) => DropdownMenuItem<String>(
                                              value: s.id,
                                              child: Text(s.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (val) => setState(
                                          () => _selectedSubcategoryId = val,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'SKU / Item Code',
                                  hintText: 'SKU-001',
                                  controller: _skuController,
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 22.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Generate SKU',
                                  onPressed: _generateSKU,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Barcode',
                                  hintText: 'Scan or enter barcode',
                                  controller: _barcodeController,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 22.0),
                                child: AppButton(
                                  text: 'Assign Code',
                                  height: 40,
                                  variant: AppButtonVariant.outline,
                                  onPressed: _generateBarcode,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Image URL (optional)',
                            hintText: 'https://example.com/image.png',
                            controller: _imageController,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Description',
                            hintText: 'Enter detailed description...',
                            controller: _descriptionController,
                          ),
                        ],
                      ),
                    ),

                    // Tab 2: Pricing
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Sales Price',
                                  hintText: '0.00',
                                  controller: _salesPriceController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sales Tax Type',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foregroundLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _salesTaxType,
                                      dropdownColor: isDark
                                          ? AppColors.cardDark
                                          : AppColors.cardLight,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                          child: Text('Without Tax'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'with',
                                          child: Text('With Tax'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inclusive',
                                          child: Text('Inclusive'),
                                        ),
                                      ],
                                      onChanged: (val) => setState(
                                        () => _salesTaxType = val ?? 'without',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Purchase Price',
                                  hintText: '0.00',
                                  controller: _purchasePriceController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Purchase Tax Type',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foregroundLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _purchaseTaxType,
                                      dropdownColor: isDark
                                          ? AppColors.cardDark
                                          : AppColors.cardLight,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                          child: Text('Without Tax'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'with',
                                          child: Text('With Tax'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'inclusive',
                                          child: Text('Inclusive'),
                                        ),
                                      ],
                                      onChanged: (val) => setState(
                                        () =>
                                            _purchaseTaxType = val ?? 'without',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Tax Rate (%)',
                            hintText: 'e.g. 18',
                            controller: _taxRateController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    // Tab 3: Stock
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Initial Stock Quantity',
                                  hintText: '0',
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'Low Stock Alert Threshold',
                                  hintText: '10',
                                  controller: _lowStockThresholdController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unit of Measure',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foregroundLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedUnit,
                                      dropdownColor: isDark
                                          ? AppColors.cardDark
                                          : AppColors.cardLight,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                      items: _unitOptions
                                          .map(
                                            (u) => DropdownMenuItem(
                                              value: u,
                                              child: Text(u.toUpperCase()),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedUnit = val ?? 'piece',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'Opening Stock Price',
                                  hintText: '0.00',
                                  controller: _openingStockPriceController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Footer Buttons
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
                      text: widget.product != null
                          ? 'Update Product'
                          : 'Create Product',
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
