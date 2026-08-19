import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/cheque_list_controller.dart';
import '../models/cheque.dart';

class ChequeFormDialog extends StatefulWidget {
  final Cheque? cheque;

  const ChequeFormDialog({super.key, this.cheque});

  @override
  State<ChequeFormDialog> createState() => _ChequeFormDialogState();
}

class _ChequeFormDialogState extends State<ChequeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _chequeNumber;
  late String _amount;
  late String _date;
  late String _partyName;
  late String _bankName;
  late String _status;

  @override
  void initState() {
    super.initState();
    final c = widget.cheque;
    _type = c?.type ?? 'received';
    _chequeNumber = c?.chequeNumber ?? '';
    _amount = c != null ? c.amount.toString() : '';
    _date = c != null
        ? c.date.split('T')[0]
        : DateTime.now().toIso8601String().split('T')[0];
    _partyName = c?.partyName ?? '';
    _bankName = c?.bankName ?? '';
    _status = c?.status ?? 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChequeListController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.cheque == null
                              ? 'New Cheque Entry'
                              : 'Edit Cheque Record',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Type Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _type = 'received'),
                          borderRadius: AppRadius.md,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _type == 'received'
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: _type == 'received'
                                      ? AppColors.primary
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Received Cheque',
                                    style: TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _type = 'issued'),
                          borderRadius: AppRadius.md,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _type == 'issued'
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: _type == 'issued'
                                      ? AppColors.primary
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Issued Cheque',
                                    style: TextStyle(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    initialValue: _chequeNumber,
                    decoration: const InputDecoration(
                      labelText: 'Cheque Number / Reference',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    onSaved: (v) => _chequeNumber = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _amount,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount (₹)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: (v) =>
                              v == null || double.tryParse(v.trim()) == null
                              ? 'Enter valid amount'
                              : null,
                          onSaved: (v) => _amount = v!.trim(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _date,
                          decoration: const InputDecoration(
                            labelText: 'Date (YYYY-MM-DD)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                          onSaved: (v) => _date = v!.trim(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _partyName,
                    decoration: const InputDecoration(
                      labelText: 'Party / Drawer Name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    onSaved: (v) => _partyName = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _bankName,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSaved: (v) => _bankName = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'Cleared',
                        child: Text('Cleared'),
                      ),
                      DropdownMenuItem(
                        value: 'Bounced',
                        child: Text('Bounced'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
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
                      const SizedBox(width: 8),
                      AppButton(
                        text: widget.cheque == null
                            ? 'Save Cheque'
                            : 'Update Record',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            controller.saveCheque({
                              'type': _type,
                              'chequeNumber': _chequeNumber,
                              'amount': double.parse(_amount),
                              'date': _date,
                              'partyName': _partyName,
                              'bankName': _bankName,
                              'status': _status,
                              'clearanceAccountType': 'bank',
                            }, editId: widget.cheque?.id);
                            Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
