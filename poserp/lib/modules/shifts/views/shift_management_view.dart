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
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;

                  final headerInfo = Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cashier Shift Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Monitor active register shifts, track opening float, and perform daily cash reconciliation.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForegroundLight,
                              ),
                              maxLines: isMobile ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final actionBtn = Obx(() {
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
                  });

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerInfo,
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: actionBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: headerInfo),
                      const SizedBox(width: 16),
                      actionBtn,
                    ],
                  );
                },
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isActive
                                            ? 'ACTIVE REGISTER SHIFT'
                                            : 'NO ACTIVE SHIFT',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 20,
                                ),
                                tooltip: 'Refresh Status',
                                onPressed: () => controller.loadCurrentShift(),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          if (isActive && shift != null) ...[
                            LayoutBuilder(
                              builder: (context, cardConstraints) {
                                final isCompact =
                                    cardConstraints.maxWidth < 650;

                                final tileCashier = _buildDetailTile(
                                  title: 'CASHIER NAME',
                                  value: shift.cashierName,
                                  icon: Icons.person_outline_rounded,
                                );
                                final tileStart = _buildDetailTile(
                                  title: 'SHIFT START TIME',
                                  value:
                                      '${shift.startTime.split('T')[0]} ${shift.startTime.contains('T') ? shift.startTime.split('T')[1].split('.')[0] : ''}',
                                  icon: Icons.access_time_rounded,
                                );
                                final tileFloat = _buildDetailTile(
                                  title: 'OPENING CASH FLOAT',
                                  value:
                                      '₹${shift.openingBalance.toStringAsFixed(2)}',
                                  icon: Icons.payments_outlined,
                                  valueColor: AppColors.primary,
                                );

                                if (isCompact) {
                                  return Column(
                                    children: [
                                      tileCashier,
                                      const SizedBox(height: 16),
                                      tileStart,
                                      const SizedBox(height: 16),
                                      tileFloat,
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: tileCashier),
                                    Expanded(child: tileStart),
                                    Expanded(child: tileFloat),
                                  ],
                                );
                              },
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
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
                                      textAlign: TextAlign.center,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
