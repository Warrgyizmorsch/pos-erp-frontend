import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../authentication/controllers/auth_controller.dart';

class DashboardPlaceholderView extends GetView<AuthController> {
  const DashboardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS ERP — Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Authentication Successful!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phase 1 Shared Foundation & Auth Module active.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 32),
                    if (user != null) ...[
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(user.name),
                        subtitle: Text(
                          '${user.email} (${user.role.toUpperCase()})',
                        ),
                      ),
                    ],
                    AppButton(
                      text: 'Open Categories Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/categories'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Subcategories Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/subcategories'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Products Catalog Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/products'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Opening Stock Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/opening-stock'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Inventory Manager Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/inventory'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Customers Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/customers'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Suppliers Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/suppliers'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Transporters Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/transporters'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open POS Cashier Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/pos'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Sales Invoices Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/sales'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Payment-In Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/sales/payment-in'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Sale Return Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/sales/return'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Purchase Bills Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/purchases'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Purchase Return / Debit Note Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/purchase-return'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Payment-Out Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/payment-out'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Expenses & Income Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/expenses'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Cash & Bank Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/cash-bank'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Cheques Register Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/cheques'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Loans Management Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/loans'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Cashier Shifts Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/shifts'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Accounting Executive Dashboard',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/accounting'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Chart of Accounts Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () =>
                          Get.toNamed('/accounting/chart-of-accounts'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Account Ledgers Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/accounting/ledgers'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Accounting Vouchers Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/accounting/vouchers'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Day Book Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/accounting/day-book'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Financial & Tax Reports Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/accounting/reports'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Activity Audit Logs Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/activity'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Data Backup & Restore Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/backup'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Barcode Label Generator Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/utilities/barcode'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open Import / Export Module',
                      variant: AppButtonVariant.secondary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/utilities/import-export'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Open System Settings Module',
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => Get.toNamed('/settings'),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Sign Out',
                      variant: AppButtonVariant.destructive,
                      width: double.infinity,
                      onPressed: () => controller.logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
