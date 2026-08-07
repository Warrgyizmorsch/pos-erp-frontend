import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/shift_controller.dart';
import '../widgets/close_shift_dialog.dart';
import '../widgets/open_shift_dialog.dart';

class ShiftManagementView extends GetView<ShiftController> {
  const ShiftManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.punch_clock_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cashier Shift Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Monitor active register shifts, track opening float, and perform daily cash reconciliation.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(() {
                    if (controller.isShiftActive) {
                      return AppButton(
                        text: 'Close & Settle Shift',
                        variant: AppButtonVariant.destructive,
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const CloseShiftDialog(),
                          );
                        },
                      );
                    } else {
                      return AppButton(
                        text: 'Start Cashier Shift',
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const OpenShiftDialog(),
                          );
                        },
                      );
                    }
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Active Shift Main Panel
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final shift = controller.currentShift.value;
                  final isActive = controller.isShiftActive;

                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isActive
                                      ? 'ACTIVE REGISTER SHIFT'
                                      : 'NO ACTIVE SHIFT',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isActive
                                                ? AppColors.success
                                                : Colors.grey)
                                            .withAlpha(25),
                                    borderRadius: AppRadius.full,
                                  ),
                                  child: Text(
                                    isActive ? 'OPEN' : 'CLOSED',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? AppColors.success
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              tooltip: 'Refresh Status',
                              onPressed: () => controller.loadCurrentShift(),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        if (isActive && shift != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailTile(
                                  title: 'CASHIER NAME',
                                  value: shift.cashierName,
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailTile(
                                  title: 'SHIFT START TIME',
                                  value:
                                      '${shift.startTime.split('T')[0]} ${shift.startTime.contains('T') ? shift.startTime.split('T')[1].split('.')[0] : ''}',
                                  icon: Icons.access_time_rounded,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailTile(
                                  title: 'OPENING CASH FLOAT',
                                  value:
                                      '₹${shift.openingBalance.toStringAsFixed(2)}',
                                  icon: Icons.payments_outlined,
                                  valueColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (shift.notes != null &&
                              shift.notes!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.inputDark
                                    : Colors.grey[100],
                                borderRadius: AppRadius.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'INITIAL NOTES',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shift.notes!,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.no_accounts_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Active Cashier Shift Currently Open',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Start a new shift before processing POS sales transactions and cash settlements.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  AppButton(
                                    text: 'Start Cashier Shift Now',
                                    icon: const Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const OpenShiftDialog(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: AppRadius.md,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
