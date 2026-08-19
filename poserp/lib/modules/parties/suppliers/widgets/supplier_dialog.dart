import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../models/supplier_payload.dart';

class SupplierDialog extends StatefulWidget {
  final Supplier? supplier;

  const SupplierDialog({super.key, this.supplier});

  static Future<void> show(BuildContext context, {Supplier? supplier}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SupplierDialog(supplier: supplier),
    );
  }

  @override
  State<SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<SupplierDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  late TextEditingController _addressController;
  late TextEditingController _shippingAddressController;
  late TextEditingController _openingBalanceController;
  late TextEditingController _creditLimitController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  String _gstType = 'Unregistered/Consumer';
  String _stateCode = '27';
  String _openingBalanceType = 'Payable';
  bool _enableShipping = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final s = widget.supplier;
    _nameController = TextEditingController(text: s?.name ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _gstController = TextEditingController(text: s?.gstNumber ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _shippingAddressController = TextEditingController(
      text: s?.shippingAddress ?? '',
    );
    _openingBalanceController = TextEditingController(
      text: s != null ? s.openingBalance.toString() : '0',
    );
    _creditLimitController = TextEditingController(
      text: s != null ? s.creditLimit.toString() : '0',
    );
    _bankNameController = TextEditingController(text: s?.bankName ?? '');
    _accountNumberController = TextEditingController(
      text: s?.accountNumber ?? '',
    );
    _ifscCodeController = TextEditingController(text: s?.ifscCode ?? '');
    _cityController = TextEditingController(text: s?.city ?? '');
    _stateController = TextEditingController(text: s?.state ?? '');
    _pincodeController = TextEditingController(text: s?.pincode ?? '');

    _gstType = s?.gstType ?? 'Unregistered/Consumer';
    _stateCode = s?.stateCode ?? '27';
    _openingBalanceType = s?.openingBalanceType ?? 'Payable';
    _enableShipping =
        s?.shippingAddress != null && s!.shippingAddress!.isNotEmpty;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _shippingAddressController.dispose();
    _openingBalanceController.dispose();
    _creditLimitController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave({bool stayOpen = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<SupplierController>();

    final payload = SupplierPayload(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gstNumber: _gstController.text.trim(),
      gstType: _gstType,
      stateCode: _stateCode,
      address: _addressController.text.trim(),
      shippingAddress: _enableShipping
          ? _shippingAddressController.text.trim()
          : null,
      openingBalance:
          double.tryParse(_openingBalanceController.text.trim()) ?? 0,
      openingBalanceType: _openingBalanceType,
      creditLimit: double.tryParse(_creditLimitController.text.trim()) ?? 0,
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      ifscCode: _ifscCodeController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
    );

    final bool success;
    if (widget.supplier != null) {
      success = await controller.updateSupplier(widget.supplier!.id, payload);
    } else {
      success = await controller.createSupplier(payload);
    }

    if (success) {
      if (!stayOpen) {
        Get.back();
      } else {
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _gstController.clear();
        _addressController.clear();
        _shippingAddressController.clear();
        _openingBalanceController.text = '0';
        _creditLimitController.text = '0';
        _bankNameController.clear();
        _accountNumberController.clear();
        _ifscCodeController.clear();
        _cityController.clear();
        _stateController.clear();
        _pincodeController.clear();
        setState(() {
          _enableShipping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SupplierController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 720),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.supplier != null ? 'Edit Supplier' : 'Add Supplier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Dialog Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Fields: Name, Phone & GSTIN
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Supplier Name',
                              hintText: 'Enter party name',
                              controller: _nameController,
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone Number',
                              hintText: 'Enter phone',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'GSTIN (Optional)',
                        hintText: 'Enter 15-digit GSTIN',
                        controller: _gstController,
                      ),
                      const SizedBox(height: 16),

                      // Tabs: GST & Address / Credit & Balance / Additional
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForegroundLight,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'GST & ADDRESS'),
                          Tab(text: 'CREDIT & BALANCE'),
                          Tab(text: 'ADDITIONAL'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: GST & Address
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GST Type',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? AppColors.foregroundDark
                                                    : AppColors.foregroundLight,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              initialValue: _gstType,
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
                                                  value:
                                                      'Unregistered/Consumer',
                                                  child: Text(
                                                    'Unregistered/Consumer',
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Registered/Regular',
                                                  child: Text(
                                                    'Registered/Regular',
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Composition',
                                                  child: Text('Composition'),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(
                                                    () => _gstType = val,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'State Code',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? AppColors.foregroundDark
                                                    : AppColors.foregroundLight,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              initialValue: _stateCode,
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
                                                  value: '27',
                                                  child: Text(
                                                    '27 — Maharashtra',
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: '24',
                                                  child: Text('24 — Gujarat'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '07',
                                                  child: Text('07 — Delhi'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '29',
                                                  child: Text('29 — Karnataka'),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(
                                                    () => _stateCode = val,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    label: 'Email Address',
                                    hintText: 'supplier@example.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    label: 'Billing Address',
                                    hintText: 'Enter full address...',
                                    controller: _addressController,
                                  ),
                                  const SizedBox(height: 8),
                                  SwitchListTile(
                                    title: const Text(
                                      'Enable Shipping Address',
                                    ),
                                    value: _enableShipping,
                                    onChanged: (val) =>
                                        setState(() => _enableShipping = val),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (_enableShipping) ...[
                                    const SizedBox(height: 6),
                                    AppTextField(
                                      label: 'Shipping Address',
                                      hintText: 'Enter shipping address...',
                                      controller: _shippingAddressController,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Tab 2: Credit & Balance
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Opening Balance',
                                          hintText: '0.00',
                                          controller: _openingBalanceController,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Balance Type',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? AppColors.foregroundDark
                                                    : AppColors.foregroundLight,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              initialValue: _openingBalanceType,
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
                                                  value: 'Payable',
                                                  child: Text(
                                                    'To Pay (Pending)',
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Receivable',
                                                  child: Text(
                                                    'To Receive (Advance)',
                                                  ),
                                                ),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(
                                                    () => _openingBalanceType =
                                                        val,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    label: 'Credit Limit Amount (₹)',
                                    hintText: '0.00',
                                    controller: _creditLimitController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),

                            // Tab 3: Additional Fields (Bank & Regional)
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bank Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Bank Name',
                                          hintText: 'HDFC Bank',
                                          controller: _bankNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Account Number',
                                          hintText: '1234567890',
                                          controller: _accountNumberController,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppTextField(
                                          label: 'IFSC Code',
                                          hintText: 'HDFC0001234',
                                          controller: _ifscCodeController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Regional Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppTextField(
                                          label: 'City',
                                          hintText: 'Mumbai',
                                          controller: _cityController,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppTextField(
                                          label: 'State',
                                          hintText: 'Maharashtra',
                                          controller: _stateController,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AppTextField(
                                          label: 'Pincode',
                                          hintText: '400001',
                                          controller: _pincodeController,
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
                    ],
                  ),
                ),
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          if (widget.supplier == null) ...[
                            AppButton(
                              text: 'Save & New',
                              variant: AppButtonVariant.outline,
                              isLoading: controller.isSubmitting.value,
                              onPressed: () => _handleSave(stayOpen: true),
                            ),
                            const SizedBox(width: 8),
                          ],
                          AppButton(
                            text: widget.supplier != null
                                ? 'Update Supplier'
                                : 'Save Supplier',
                            isLoading: controller.isSubmitting.value,
                            onPressed: () => _handleSave(stayOpen: false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
