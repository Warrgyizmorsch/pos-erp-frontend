import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_roles.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/user.dart';
import '../authentication/controllers/auth_controller.dart';

class DashboardPlaceholderView extends GetView<AuthController> {
  const DashboardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS ERP — Executive Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Notifications',
            onPressed: () => Get.toNamed('/notifications'),
          ),
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
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active Role & Demo Switcher Card
                  Obx(() {
                    final user = controller.currentUser.value;
                    final currentRole = user?.role ?? AppRoles.admin;

                    return AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Active User: ${user?.name ?? "User"}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: AppRadius.full,
                                ),
                                child: Text(
                                  AppRoles.getLabel(currentRole).toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Demo Role Switcher (Test Permission Guards Live):',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _roleChip('admin', 'Admin', currentRole),
                              _roleChip('manager', 'Manager', currentRole),
                              _roleChip(
                                'accountant',
                                'Accountant',
                                currentRole,
                              ),
                              _roleChip(
                                'stock_manager',
                                'Stock Mgr',
                                currentRole,
                              ),
                              _roleChip('cashier', 'Cashier', currentRole),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Dynamic Authorized Modules List
                  Obx(() {
                    final user = controller.currentUser.value;
                    final role = user?.role ?? AppRoles.admin;

                    return AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Authorized System Modules',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Only modules permitted for your active role are displayed below.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Divider(height: 24),

                          // Inventory Master Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.inventoryRoles,
                          )) ...[
                            _moduleButton(
                              'Categories Module',
                              '/categories',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Subcategories Module',
                              '/subcategories',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Products Catalog',
                              '/products',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Opening Stock Manager',
                              '/opening-stock',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Inventory Manager',
                              '/inventory',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Parties Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.partiesRoles,
                          )) ...[
                            _moduleButton(
                              'Customers Module',
                              '/customers',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Suppliers Module',
                              '/suppliers',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Transporters Module',
                              '/transporters',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Sales & POS Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.salesRoles,
                          )) ...[
                            _moduleButton(
                              'POS Cashier Terminal',
                              '/pos',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'POS Dedicated Checkout',
                              '/checkout',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Sales Invoices',
                              '/sales',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Payment-In Register',
                              '/sales/payment-in',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Sale Return / Credit Note',
                              '/sales/return',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Purchases Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.purchaseRoles,
                          )) ...[
                            _moduleButton(
                              'Purchase Bills',
                              '/purchases',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Purchase Return / Debit Note',
                              '/purchase-return',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Payment-Out Register',
                              '/payment-out',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Expenses & Income Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.expenseRoles,
                          )) ...[
                            _moduleButton(
                              'Expenses Manager',
                              '/expenses',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Indirect Income',
                              '/expenses/income',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Cash & Bank Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.cashBankRoles,
                          )) ...[
                            _moduleButton(
                              'Petty Cash Register',
                              '/cash',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Bank Accounts Registry',
                              '/bank',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Cash & Bank Ledger',
                              '/cash-bank',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Cheques Register',
                              '/cheques',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Loans Management',
                              '/loans',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Cashier Shifts Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.shiftRoles,
                          )) ...[
                            _moduleButton(
                              'Cashier Shifts Manager',
                              '/shifts',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Accounting Engine Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.accountingRoles,
                          )) ...[
                            _moduleButton(
                              'Accounting Dashboard',
                              '/accounting',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Chart of Accounts',
                              '/accounting/chart-of-accounts',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Ledger Accounts',
                              '/accounting/ledgers',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Accounting Vouchers',
                              '/accounting/vouchers',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Day Book',
                              '/accounting/day-book',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Trial Balance',
                              '/accounting/trial-balance',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Financial Reports',
                              '/accounting/reports',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Accounting Settings',
                              '/accounting/settings',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Health Diagnostics',
                              '/accounting/health',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Reconciliation Hub',
                              '/accounting/reconciliation',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Bank Statement Import',
                              '/accounting/bank-statement-import',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Reports & BI Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.reportsRoles,
                          )) ...[
                            _moduleButton(
                              'Reports & Analytics',
                              '/reports',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Admin Only Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.adminOnlyRoles,
                          )) ...[
                            _moduleButton(
                              'Activity Audit Logs',
                              '/activity',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Backup & Restore',
                              '/backup',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'System Settings',
                              '/settings',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Utilities Group
                          if (PermissionService.hasRole(
                            role,
                            PermissionService.utilityRoles,
                          )) ...[
                            _moduleButton(
                              'Barcode Generator',
                              '/utilities/barcode',
                              AppButtonVariant.primary,
                            ),
                            const SizedBox(height: 8),
                            _moduleButton(
                              'Import / Export Data',
                              '/utilities/import-export',
                              AppButtonVariant.secondary,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Notifications
                          _moduleButton(
                            'Notifications & Alerts',
                            '/notifications',
                            AppButtonVariant.outline,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String roleKey, String label, String currentRole) {
    final isSelected = currentRole == roleKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        final existingUser = controller.currentUser.value;
        if (existingUser != null) {
          controller.currentUser.value = User(
            id: existingUser.id,
            name: existingUser.name,
            email: existingUser.email,
            role: roleKey,
            phone: existingUser.phone,
            avatar: existingUser.avatar,
            isActive: existingUser.isActive,
            createdAt: existingUser.createdAt,
            updatedAt: existingUser.updatedAt,
          );
          Get.snackbar(
            'Role Switched',
            'Active role changed to ${AppRoles.getLabel(roleKey)}.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        }
      },
    );
  }

  Widget _moduleButton(String title, String route, AppButtonVariant variant) {
    return AppButton(
      text: title,
      variant: variant,
      width: double.infinity,
      onPressed: () => Get.toNamed(route),
    );
  }
}
