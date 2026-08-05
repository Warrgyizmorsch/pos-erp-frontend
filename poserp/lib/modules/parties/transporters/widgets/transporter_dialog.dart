import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/transporter_controller.dart';
import '../models/transporter.dart';
import '../models/transporter_payload.dart';

class TransporterDialog extends StatefulWidget {
  final Transporter? transporter;

  const TransporterDialog({super.key, this.transporter});

  static Future<void> show(
    BuildContext context, {
    Transporter? transporter,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TransporterDialog(transporter: transporter),
    );
  }

  @override
  State<TransporterDialog> createState() => _TransporterDialogState();
}

class _TransporterDialogState extends State<TransporterDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final t = widget.transporter;
    _nameController = TextEditingController(text: t?.name ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _vehicleNumberController = TextEditingController(
      text: t?.vehicleNumber ?? '',
    );
    _addressController = TextEditingController(text: t?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<TransporterController>();

    final payload = TransporterPayload(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim(),
      address: _addressController.text.trim(),
    );

    final bool success;
    if (widget.transporter != null) {
      success = await controller.updateTransporter(
        widget.transporter!.id,
        payload,
      );
    } else {
      success = await controller.createTransporter(payload);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<TransporterController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                      widget.transporter != null
                          ? 'Edit Transporter'
                          : 'Add Transporter',
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
                Text(
                  'Enter transporter & vehicle details',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForegroundLight,
                  ),
                ),
                const SizedBox(height: 20),

                // Name & Mobile Number
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Transporter Name',
                        hintText: 'Enter name',
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
                        label: 'Mobile Number',
                        hintText: '9876543210',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mobile is required';
                          }
                          final regExp = RegExp(r'^[6-9]\d{9}$');
                          if (!regExp.hasMatch(v.trim())) {
                            return 'Valid 10-digit mobile required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vehicle Number
                AppTextField(
                  label: 'Vehicle Number (Optional)',
                  hintText: 'e.g. MH12AB1234',
                  controller: _vehicleNumberController,
                ),
                const SizedBox(height: 12),

                // Address
                AppTextField(
                  label: 'Address (Optional)',
                  hintText: 'Enter office or depot address...',
                  controller: _addressController,
                ),
                const SizedBox(height: 24),

                // Dialog Buttons
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        text: widget.transporter != null ? 'Update' : 'Create',
                        isLoading: controller.isSubmitting.value,
                        onPressed: () => _handleSave(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
