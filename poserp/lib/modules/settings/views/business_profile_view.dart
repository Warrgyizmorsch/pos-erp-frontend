import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/gst_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/business_profile_controller.dart';

class BusinessProfileView extends GetView<BusinessProfileController> {
  const BusinessProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Business Profile',
        subtitle: 'Manage company identity, tax, bank & invoice terms',
        showBackButton: true,
        actions: [
          Obx(
            () => TextButton.icon(
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(controller.isSaving.value ? 'Saving...' : 'Save'),
              onPressed: controller.isSaving.value ? null : controller.saveProfile,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const Center(child: LoadingIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identity Banner Card
                _buildIdentityHeader(context, isDark),
                const SizedBox(height: 16),

                // Section 1: Business Identity
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.storefront_rounded,
                  title: 'Store & Business Identity',
                  subtitle: 'Official business details used on receipts, invoices & tax filings',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: controller.businessNameController,
                        label: 'Business Name *',
                        hint: 'e.g. Acme Retail Superstore',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: controller.taglineController,
                        label: 'Tagline / Slogan',
                        hint: 'e.g. Quality & Trust Always',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.phoneController,
                              label: 'Business Phone',
                              hint: '+91 98765 43210',
                              keyboardType: TextInputType.phone,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.emailController,
                              label: 'Business Email',
                              hint: 'billing@mybusiness.com',
                              keyboardType: TextInputType.emailAddress,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Accounting Beginning Date Picker
                      _buildDatePicker(context, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: GST & Tax Identification
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.receipt_long_rounded,
                  title: 'GST & State Tax Identification',
                  subtitle: 'State code and GSTIN for automated GSTR reports and E-invoices',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: controller.gstinController,
                        label: 'GSTIN (Goods and Services Tax ID)',
                        hint: 'e.g. 27AAAAA0000A1Z5',
                        textCapitalization: TextCapitalization.characters,
                        onChanged: controller.onGstinChanged,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Business Segment
                          Expanded(
                            child: _buildDropdownField<String>(
                              label: 'Business Segment',
                              initialValue: controller.selectedBusinessType.value,
                              items: controller.businessTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controller.selectedBusinessType.value = val;
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Pincode
                          Expanded(
                            child: _buildTextField(
                              controller: controller.pincodeController,
                              label: 'Postal Pincode',
                              hint: '6-digit code',
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // State Selection Dropdown
                      _buildStateDropdown(isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 3: Office Address
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.location_on_outlined,
                  title: 'Registered Office Address',
                  subtitle: 'Physical storefront or headquarters address printed on bills',
                  child: _buildTextField(
                    controller: controller.addressController,
                    label: 'Full Street Address',
                    hint: 'Shop #12, Market Complex, MG Road...',
                    maxLines: 3,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Bank Account & Payment QR Details
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.account_balance_rounded,
                  title: 'Bank & Digital Settlement Details',
                  subtitle: 'Account details and UPI VPA printed on B2B invoices for quick settlement',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.bankNameController,
                              label: 'Bank Name',
                              hint: 'e.g. HDFC Bank Ltd',
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.accountNumberController,
                              label: 'Account Number',
                              hint: '50100XXXXXXXX',
                              keyboardType: TextInputType.number,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.ifscCodeController,
                              label: 'IFSC Code',
                              hint: 'HDFC0001234',
                              textCapitalization: TextCapitalization.characters,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.branchController,
                              label: 'Branch Name',
                              hint: 'Indiranagar Branch',
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: controller.upiIdController,
                        label: 'UPI Virtual Payment Address (VPA)',
                        hint: 'mybusiness@okaxis or 9876543210@paytm',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 5: Branding & Image Assets
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.image_outlined,
                  title: 'Branding Assets & Logo',
                  subtitle: 'Store logo and digital authorized signatory image URLs',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: controller.logoUrlController,
                        label: 'Company Logo URL',
                        hint: 'https://example.com/logo.png',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: controller.signatureUrlController,
                        label: 'Authorized E-Signature URL',
                        hint: 'https://example.com/signature.png',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section 6: Default Invoice Terms
                _buildSectionCard(
                  context,
                  isDark: isDark,
                  icon: Icons.description_outlined,
                  title: 'Default Invoice Terms & Conditions',
                  subtitle: 'Legal footer text displayed on printed thermal receipts & PDF invoices',
                  child: _buildTextField(
                    controller: controller.invoiceTermsController,
                    label: 'Terms & Conditions',
                    hint: '1. Goods once sold will not be returned.\n2. Interest @18% p.a. will be charged after due date.\n3. Subject to local jurisdiction.',
                    maxLines: 4,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Discard Changes',
                        variant: AppButtonVariant.outline,
                        height: 44,
                        onPressed: controller.discardChanges,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppButton(
                        text: controller.isSaving.value ? 'Saving Profile...' : 'Save Profile',
                        variant: AppButtonVariant.primary,
                        height: 44,
                        isLoading: controller.isSaving.value,
                        onPressed: controller.saveProfile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIdentityHeader(BuildContext context, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Center(
              child: controller.logoUrlController.text.isNotEmpty
                  ? ClipRRect(
                      borderRadius: AppRadius.md,
                      child: Image.network(
                        controller.logoUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.storefront_rounded,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.storefront_rounded,
                      size: 30,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      controller.businessNameController.text.isNotEmpty
                          ? controller.businessNameController.text
                          : 'Your Business Name',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: AppRadius.full,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: AppColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Active Profile',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  controller.taglineController.text.isNotEmpty
                      ? controller.taglineController.text
                      : 'Legal business entity used for invoicing, VAT/GST and reports',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? initialValue,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: initialValue,
          items: items,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown(bool isDark) {
    return Obx(() {
      final currentCode = controller.selectedStateCode.value;
      final effectiveCode = gstStateCodes.containsKey(currentCode) ? currentCode : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'State / GST Jurisdiction (Auto-derived from GSTIN)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: effectiveCode,
            items: gstStateCodes.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  '${entry.key} - ${entry.value}',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (code) {
              if (code != null) controller.onStateChanged(code);
            },
            hint: const Text('Select State or enter GSTIN', style: TextStyle(fontSize: 12, color: Colors.grey)),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDatePicker(BuildContext context, bool isDark) {
    return Obx(() {
      final date = controller.beginningDate.value;
      final dateStr = date != null
          ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : 'Select Start Date';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Books / Accounting Beginning Date',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: AppRadius.md,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                controller.beginningDate.value = picked;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputDark : Colors.grey[100],
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? (isDark ? AppColors.foregroundDark : AppColors.foregroundLight)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
