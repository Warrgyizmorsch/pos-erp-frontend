import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../permissions/permission_service.dart';
import 'app_top_bar.dart';

class MoreModulesView extends StatelessWidget {
  const MoreModulesView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userRole = authController.currentUser.value?.role ?? '';

    return Scaffold(
      appBar: AppTopBar(
        title: 'More System Modules',
        subtitle: 'Access all enterprise ERP capabilities & tools',
        showBackButton: false,
        userRole: userRole,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accounting & Financial Group
              if (PermissionService.hasRole(
                userRole,
                PermissionService.accountingRoles,
              )) ...[
                _buildSectionHeader(
                  context: context,
                  title: 'Accounting & Financial Engine',
                  icon: Icons.account_balance_outlined,
                  color: AppColors.primary,
                ),
                _buildGridSection([
                  _ModuleItem(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Accounting Dashboard',
                    route: '/accounting',
                  ),
                  _ModuleItem(
                    icon: Icons.account_tree_outlined,
                    label: 'Chart of Accounts',
                    route: '/accounting/chart-of-accounts',
                  ),
                  _ModuleItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Ledger Accounts',
                    route: '/accounting/ledgers',
                  ),
                  _ModuleItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Accounting Vouchers',
                    route: '/accounting/vouchers',
                  ),
                  _ModuleItem(
                    icon: Icons.book_outlined,
                    label: 'Day Book Report',
                    route: '/accounting/day-book',
                  ),
                  _ModuleItem(
                    icon: Icons.scale_rounded,
                    label: 'Trial Balance',
                    route: '/accounting/trial-balance',
                  ),
                  _ModuleItem(
                    icon: Icons.receipt_rounded,
                    label: 'GST & Tax Reports',
                    route: '/accounting/gst',
                  ),
                  _ModuleItem(
                    icon: Icons.pie_chart_outline_rounded,
                    label: 'Financial Reports',
                    route: '/accounting/reports',
                  ),
                  _ModuleItem(
                    icon: Icons.health_and_safety_outlined,
                    label: 'Accounting Health',
                    route: '/accounting/health',
                  ),
                  _ModuleItem(
                    icon: Icons.published_with_changes_rounded,
                    label: 'Reconciliation Hub',
                    route: '/accounting/reconciliation',
                  ),
                  _ModuleItem(
                    icon: Icons.upload_file_rounded,
                    label: 'Bank Importer',
                    route: '/accounting/bank-statement-import',
                  ),
                  _ModuleItem(
                    icon: Icons.settings_applications_outlined,
                    label: 'Accounting Config',
                    route: '/accounting/settings',
                  ),
                ]),
                const SizedBox(height: 16),
              ],

              // Cash & Banking Group
              if (PermissionService.hasRole(
                userRole,
                PermissionService.cashBankRoles,
              )) ...[
                _buildSectionHeader(
                  context: context,
                  title: 'Cash & Banking',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.info,
                ),
                _buildGridSection([
                  _ModuleItem(
                    icon: Icons.payments_outlined,
                    label: 'Petty Cash',
                    route: '/cash',
                  ),
                  _ModuleItem(
                    icon: Icons.account_balance_rounded,
                    label: 'Bank Accounts',
                    route: '/bank',
                  ),
                  _ModuleItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Cash & Bank Ledger',
                    route: '/cash-bank',
                  ),
                  _ModuleItem(
                    icon: Icons.payment_rounded,
                    label: 'Cheques Register',
                    route: '/cheques',
                  ),
                  _ModuleItem(
                    icon: Icons.request_quote_outlined,
                    label: 'Loan Accounts',
                    route: '/loans',
                  ),
                ]),
                const SizedBox(height: 16),
              ],

              // Parties & Contacts Group
              if (PermissionService.hasRole(
                userRole,
                PermissionService.partiesRoles,
              )) ...[
                _buildSectionHeader(
                  context: context,
                  title: 'Parties & Contacts',
                  icon: Icons.people_outline,
                  color: AppColors.primary,
                ),
                _buildGridSection([
                  _ModuleItem(
                    icon: Icons.person_rounded,
                    label: 'Customers',
                    route: '/customers',
                  ),
                  _ModuleItem(
                    icon: Icons.storefront_rounded,
                    label: 'Suppliers & Vendors',
                    route: '/suppliers',
                  ),
                  _ModuleItem(
                    icon: Icons.local_shipping_rounded,
                    label: 'Transporters',
                    route: '/transporters',
                  ),
                ]),
                const SizedBox(height: 16),
              ],

              // Shift & Utility Tools Group
              _buildSectionHeader(
                context: context,
                title: 'Shift & Utility Tools',
                icon: Icons.construction_outlined,
                color: AppColors.warning,
              ),
              _buildGridSection([
                if (PermissionService.hasRole(
                  userRole,
                  PermissionService.shiftRoles,
                ))
                  _ModuleItem(
                    icon: Icons.schedule_rounded,
                    label: 'Cashier Shifts',
                    route: '/shifts',
                  ),
                if (PermissionService.hasRole(
                  userRole,
                  PermissionService.utilityRoles,
                )) ...[
                  _ModuleItem(
                    icon: Icons.qr_code_2_rounded,
                    label: 'Barcode Generator',
                    route: '/utilities/barcode',
                  ),
                  _ModuleItem(
                    icon: Icons.import_export_rounded,
                    label: 'Import / Export',
                    route: '/utilities/import-export',
                  ),
                ],
              ]),
              const SizedBox(height: 16),

              // Administration & Security Group
              if (PermissionService.hasRole(
                userRole,
                PermissionService.adminOnlyRoles,
              )) ...[
                _buildSectionHeader(
                  context: context,
                  title: 'Administration & Security',
                  icon: Icons.admin_panel_settings_outlined,
                  color: AppColors.danger,
                ),
                _buildGridSection([
                  _ModuleItem(
                    icon: Icons.history_rounded,
                    label: 'Activity Audit Logs',
                    route: '/activity',
                  ),
                  _ModuleItem(
                    icon: Icons.cloud_sync_rounded,
                    label: 'Backup & Restore',
                    route: '/backup',
                  ),
                  _ModuleItem(
                    icon: Icons.tune_rounded,
                    label: 'System Settings',
                    route: '/settings',
                  ),
                ]),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection(List<_ModuleItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 400 ? 2 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return InkWell(
              onTap: () => Get.toNamed(item.route),
              borderRadius: AppRadius.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withAlpha(20),
                      child: Icon(
                        item.icon,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String label;
  final String route;

  _ModuleItem({required this.icon, required this.label, required this.route});
}
