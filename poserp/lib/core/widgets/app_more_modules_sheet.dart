import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../permissions/permission_service.dart';

class AppMoreModulesSheet extends StatelessWidget {
  const AppMoreModulesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userRole = authController.currentUser.value?.role ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: AppRadius.full,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'More System Modules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Accounting Group
                    if (PermissionService.hasRole(
                      userRole,
                      PermissionService.accountingRoles,
                    )) ...[
                      _buildSectionTitle('Accounting & Financial Engine'),
                      _buildTile(
                        Icons.account_balance_outlined,
                        'Accounting Dashboard',
                        '/accounting',
                      ),
                      _buildTile(
                        Icons.layers_outlined,
                        'Chart of Accounts',
                        '/accounting/chart-of-accounts',
                      ),
                      _buildTile(
                        Icons.list_alt_rounded,
                        'Ledger Accounts',
                        '/accounting/ledgers',
                      ),
                      _buildTile(
                        Icons.receipt_long_rounded,
                        'Accounting Vouchers',
                        '/accounting/vouchers',
                      ),
                      _buildTile(
                        Icons.book_outlined,
                        'Day Book Report',
                        '/accounting/day-book',
                      ),
                      _buildTile(
                        Icons.bar_chart_rounded,
                        'Trial Balance',
                        '/accounting/trial-balance',
                      ),
                      _buildTile(
                        Icons.pie_chart_outline_rounded,
                        'Financial Reports',
                        '/accounting/reports',
                      ),
                      _buildTile(
                        Icons.health_and_safety_outlined,
                        'Accounting Health Diagnostics',
                        '/accounting/health',
                      ),
                      _buildTile(
                        Icons.published_with_changes_rounded,
                        'Reconciliation Hub',
                        '/accounting/reconciliation',
                      ),
                      _buildTile(
                        Icons.upload_file_rounded,
                        'Bank Statement Auto-Importer',
                        '/accounting/bank-statement-import',
                      ),
                      _buildTile(
                        Icons.settings_outlined,
                        'Accounting Settings',
                        '/accounting/settings',
                      ),
                      const Divider(height: 24),
                    ],

                    // Cash & Bank Group
                    if (PermissionService.hasRole(
                      userRole,
                      PermissionService.cashBankRoles,
                    )) ...[
                      _buildSectionTitle('Cash & Banking'),
                      _buildTile(
                        Icons.currency_rupee_rounded,
                        'Petty Cash',
                        '/cash',
                      ),
                      _buildTile(
                        Icons.account_balance_rounded,
                        'Bank Accounts Registry',
                        '/bank',
                      ),
                      _buildTile(
                        Icons.swap_horiz_rounded,
                        'Cash & Bank Ledger History',
                        '/cash-bank',
                      ),
                      _buildTile(
                        Icons.payment_rounded,
                        'Cheques Register',
                        '/cheques',
                      ),
                      _buildTile(
                        Icons.request_quote_outlined,
                        'Loan Accounts',
                        '/loans',
                      ),
                      const Divider(height: 24),
                    ],

                    // Shifts & Utilities Group
                    _buildSectionTitle('Shift & Utility Tools'),
                    if (PermissionService.hasRole(
                      userRole,
                      PermissionService.shiftRoles,
                    ))
                      _buildTile(
                        Icons.schedule_rounded,
                        'Cashier Shift Manager',
                        '/shifts',
                      ),
                    if (PermissionService.hasRole(
                      userRole,
                      PermissionService.utilityRoles,
                    )) ...[
                      _buildTile(
                        Icons.qr_code_2_rounded,
                        'Barcode Label Generator',
                        '/utilities/barcode',
                      ),
                      _buildTile(
                        Icons.import_export_rounded,
                        'Import / Export Data',
                        '/utilities/import-export',
                      ),
                    ],
                    const Divider(height: 24),

                    // Admin & Settings Group
                    if (PermissionService.hasRole(
                      userRole,
                      PermissionService.adminOnlyRoles,
                    )) ...[
                      _buildSectionTitle('Administration & Security'),
                      _buildTile(
                        Icons.history_rounded,
                        'Activity Audit Logs',
                        '/activity',
                      ),
                      _buildTile(
                        Icons.cloud_sync_rounded,
                        'Data Backup & Restore',
                        '/backup',
                      ),
                      _buildTile(
                        Icons.tune_rounded,
                        'System Settings',
                        '/settings',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String route) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary.withAlpha(20),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: Colors.grey,
      ),
      onTap: () {
        Get.back();
        Get.toNamed(route);
      },
    );
  }
}
