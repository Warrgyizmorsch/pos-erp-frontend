import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/loan_controller.dart';
import '../models/loan.dart';

class LoanFormDialog extends StatefulWidget {
  final Loan? loan;

  const LoanFormDialog({super.key, this.loan});

  @override
  State<LoanFormDialog> createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _loanName;
  late String _lenderName;
  late String _totalAmount;
  late String _interestRate;
  late String _status;

  @override
  void initState() {
    super.initState();
    final l = widget.loan;
    _loanName = l?.loanName ?? '';
    _lenderName = l?.lenderName ?? '';
    _totalAmount = l != null ? l.totalAmount.toString() : '';
    _interestRate = l != null ? l.interestRate.toString() : '';
    _status = l?.status ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoanController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                        Icons.account_balance_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.loan == null
                            ? 'New Loan Account'
                            : 'Edit Loan Account',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  TextFormField(
                    initialValue: _loanName,
                    decoration: const InputDecoration(
                      labelText: 'Loan Account Name',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    onSaved: (v) => _loanName = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: _lenderName,
                    decoration: const InputDecoration(
                      labelText: 'Lender Name / Bank',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                    onSaved: (v) => _lenderName = v!.trim(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _totalAmount,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Sanctioned Amount (₹)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: (v) =>
                              v == null ||
                                  double.tryParse(v.trim()) == null ||
                                  double.parse(v.trim()) <= 0
                              ? 'Enter valid amount'
                              : null,
                          onSaved: (v) => _totalAmount = v!.trim(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: _interestRate,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Interest Rate (%)',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          validator: (v) =>
                              v == null ||
                                  double.tryParse(v.trim()) == null ||
                                  double.parse(v.trim()) < 0
                              ? 'Invalid rate'
                              : null,
                          onSaved: (v) => _interestRate = v!.trim(),
                        ),
                      ),
                    ],
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
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Closed', child: Text('Closed')),
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
                        text: widget.loan == null
                            ? 'Save Account'
                            : 'Update Account',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            controller.saveLoan({
                              'loanName': _loanName,
                              'lenderName': _lenderName,
                              'totalAmount': double.parse(_totalAmount),
                              'interestRate': double.parse(_interestRate),
                              'currentBalance': double.parse(_totalAmount),
                              'status': _status,
                            }, editId: widget.loan?.id);
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
