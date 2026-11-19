import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/godown_controller.dart';
import '../models/godown.dart';

class GodownDialog extends StatefulWidget {
  final Godown? godown;

  const GodownDialog({super.key, this.godown});

  static Future<void> show(BuildContext context, {Godown? godown}) {
    return showDialog(
      context: context,
      builder: (_) => GodownDialog(godown: godown),
    );
  }

  @override
  State<GodownDialog> createState() => _GodownDialogState();
}

class _GodownDialogState extends State<GodownDialog> {
  final GodownController controller = Get.find<GodownController>();

  late final TextEditingController nameCtrl;
  late final TextEditingController codeCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController capacityCtrl;
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.godown?.name ?? '');
    codeCtrl = TextEditingController(text: widget.godown?.code ?? '');
    locationCtrl = TextEditingController(text: widget.godown?.location ?? '');
    capacityCtrl = TextEditingController(
      text: widget.godown != null && widget.godown!.capacity > 0
          ? widget.godown!.capacity.toStringAsFixed(0)
          : '',
    );
    isDefault = widget.godown?.isDefault ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    locationCtrl.dispose();
    capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await controller.saveGodown(
      id: widget.godown?.id,
      name: nameCtrl.text,
      code: codeCtrl.text,
      location: locationCtrl.text,
      capacity: double.tryParse(capacityCtrl.text) ?? 0.0,
      isDefault: isDefault,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.godown != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: AppRadius.md,
                  ),
                  child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Godown / Store' : 'Add New Godown / Store',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form Fields
            AppTextField(
              controller: nameCtrl,
              label: 'Godown / Store Name *',
              hintText: 'e.g. Main Central Warehouse',
              isRequired: true,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: codeCtrl,
                    label: 'Code / Tag *',
                    hintText: 'e.g. WH-01',
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: capacityCtrl,
                    label: 'Capacity (Units)',
                    hintText: 'e.g. 5000',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            AppTextField(
              controller: locationCtrl,
              label: 'Physical Address / Rack Location',
              hintText: 'e.g. Ground Floor, Sector 4, Warehouse Zone',
            ),
            const SizedBox(height: 12),

            InkWell(
              borderRadius: AppRadius.sm,
              onTap: () => setState(() => isDefault = !isDefault),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: isDefault,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => isDefault = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Set as Default Store for Sales & POS',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => AppButton(
                    text: isEdit ? 'Save Changes' : 'Create Godown',
                    variant: AppButtonVariant.primary,
                    isLoading: controller.isSubmitting.value,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
