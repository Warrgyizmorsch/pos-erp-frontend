import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../models/customer_payload.dart';

class CustomerDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerDialog({super.key, this.customer});

  static Future<void> show(BuildContext context, {Customer? customer}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerDialog(customer: customer),
    );
  }

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  late TextEditingController _stateCodeController;
  late TextEditingController _addressController;
  late TextEditingController _openingBalanceController;
  late TextEditingController _openingBalanceDateController;
  late TextEditingController _creditLimitController;

  String _openingBalanceType = 'Receivable';
  bool _hasCustomCreditLimit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _gstController = TextEditingController(text: c?.gstNumber ?? '');
    _stateCodeController = TextEditingController(text: c?.stateCode ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _openingBalanceController = TextEditingController(
      text: c != null ? c.openingBalance.toString() : '0',
    );
    _openingBalanceDateController = TextEditingController(
      text:
          c?.openingBalanceDate ??
          DateTime.now().toIso8601String().split('T')[0],
    );
    _creditLimitController = TextEditingController(
      text: c != null ? c.creditLimit.toString() : '0',
    );

    _openingBalanceType = c?.openingBalanceType ?? 'Receivable';
    _hasCustomCreditLimit = (c != null && c.creditLimit > 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _stateCodeController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    _openingBalanceDateController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _handleSave({bool stayOpen = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<CustomerController>();

    final payload = CustomerPayload(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gstNumber: _gstController.text.trim(),
      address: _addressController.text.trim(),
      stateCode: _stateCodeController.text.trim(),
      openingBalance:
          double.tryParse(_openingBalanceController.text.trim()) ?? 0,
      openingBalanceType: _openingBalanceType,
      openingBalanceDate: _openingBalanceDateController.text.trim(),
      creditLimit: _hasCustomCreditLimit
          ? (double.tryParse(_creditLimitController.text.trim()) ?? 0)
          : 0,
    );

    final bool success;
    if (widget.customer != null) {
      success = await controller.updateCustomer(widget.customer!.id, payload);
    } else {
      success = await controller.createCustomer(payload);
    }

    if (success) {
      if (!stayOpen) {
        Get.back();
      } else {
        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _gstController.clear();
        _stateCodeController.clear();
        _addressController.clear();
        _openingBalanceController.text = '0';
        _creditLimitController.text = '0';
        setState(() {
          _hasCustomCreditLimit = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<CustomerController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 720),
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
                    widget.customer != null ? 'Edit Customer' : 'Add Customer',
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 450;

                      final nameField = AppTextField(
                        label: 'Customer Name',
                        hintText: 'Enter name',
                        controller: _nameController,
                        isRequired: true,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      );

                      final phoneField = AppTextField(
                        label: 'Phone Number',
                        hintText: 'Enter phone',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Phone is required'
                            : null,
                      );

                      final emailField = AppTextField(
                        label: 'Email Address',
                        hintText: 'customer@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      );

                      final stateField = AppTextField(
                        label: 'State Code',
                        hintText: 'e.g. 27',
                        controller: _stateCodeController,
                      );

                      return Column(
                        children: [
                          if (isMobile) ...[
                            nameField,
                            const SizedBox(height: 10),
                            phoneField,
                          ] else
                            Row(
                              children: [
                                Expanded(child: nameField),
                                const SizedBox(width: 12),
                                Expanded(child: phoneField),
                              ],
                            ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'GSTIN (Optional)',
                            hintText: 'Enter 15-digit GSTIN',
                            controller: _gstController,
                          ),
                          const SizedBox(height: 16),

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
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            height: 280,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: GST & Address
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (isMobile) ...[
                                        emailField,
                                        const SizedBox(height: 10),
                                        stateField,
                                      ] else
                                        Row(
                                          children: [
                                            Expanded(child: emailField),
                                            const SizedBox(width: 12),
                                            Expanded(child: stateField),
                                          ],
                                        ),
                                      const SizedBox(height: 12),
                                      AppTextField(
                                        label: 'Billing Address',
                                        hintText:
                                            'Enter full billing address...',
                                        controller: _addressController,
                                      ),
                                    ],
                                  ),
                                ),

                                // Tab 2: Credit & Balance
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppTextField(
                                              label: 'Opening Balance',
                                              hintText: '0.00',
                                              controller:
                                                  _openingBalanceController,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                        ? AppColors
                                                              .foregroundDark
                                                        : AppColors
                                                              .foregroundLight,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                DropdownButtonFormField<String>(
                                                  isExpanded: true,
                                                  initialValue:
                                                      _openingBalanceType,
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
                                                      borderRadius:
                                                          AppRadius.lg,
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                  .inputDark
                                                            : AppColors
                                                                  .inputLight,
                                                      ),
                                                    ),
                                                  ),
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'Receivable',
                                                      child: Text('To Receive'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'Payable',
                                                      child: Text('To Pay'),
                                                    ),
                                                  ],
                                                  onChanged: (val) {
                                                    if (val != null) {
                                                      setState(
                                                        () =>
                                                            _openingBalanceType =
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
                                        label: 'As Of Date',
                                        hintText: 'YYYY-MM-DD',
                                        controller:
                                            _openingBalanceDateController,
                                      ),
                                      const SizedBox(height: 16),
                                      SwitchListTile(
                                        title: const Text(
                                          'Custom Credit Limit',
                                        ),
                                        subtitle: const Text(
                                          'Set maximum credit limit for this customer',
                                        ),
                                        value: _hasCustomCreditLimit,
                                        onChanged: (val) => setState(
                                          () => _hasCustomCreditLimit = val,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      if (_hasCustomCreditLimit) ...[
                                        const SizedBox(height: 8),
                                        AppTextField(
                                          label: 'Credit Limit Amount (₹)',
                                          hintText: 'Enter limit amount',
                                          controller: _creditLimitController,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      variant: AppButtonVariant.ghost,
                      onPressed: () => Get.back(),
                    ),
                    Row(
                      children: [
                        if (widget.customer == null) ...[
                          AppButton(
                            text: 'Save & New',
                            variant: AppButtonVariant.outline,
                            isLoading: controller.isSubmitting.value,
                            onPressed: () => _handleSave(stayOpen: true),
                          ),
                          const SizedBox(width: 8),
                        ],
                        AppButton(
                          text: widget.customer != null ? 'Update' : 'Save',
                          isLoading: controller.isSubmitting.value,
                          onPressed: () => _handleSave(stayOpen: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
