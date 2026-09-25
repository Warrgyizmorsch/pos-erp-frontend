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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final currentUser = authController.currentUser.value;
      final userRole = currentUser?.role ?? '';

      final hasAccounting = PermissionService.hasPermission('accounting', user: currentUser);
      final hasReports = PermissionService.hasPermission('reports', user: currentUser);
      final hasCash = PermissionService.hasPermission('cash', user: currentUser);
      final hasBank = PermissionService.hasPermission('bank', user: currentUser);
      final hasCashBank = PermissionService.hasPermission('cash-bank', user: currentUser);
      final hasCheques = PermissionService.hasPermission('cheques', user: currentUser);
      final hasLoans = PermissionService.hasPermission('loans', user: currentUser);
      final hasCustomers = PermissionService.hasPermission('customers', user: currentUser);
      final hasSuppliers = PermissionService.hasPermission('suppliers', user: currentUser);
      final hasTransporters = PermissionService.hasPermission('transporters', user: currentUser);
      final hasProducts = PermissionService.hasPermission('products', user: currentUser);
      final hasCategories = PermissionService.hasPermission('categories', user: currentUser);
      final hasSubcategories = PermissionService.hasPermission('subcategories', user: currentUser);
      final hasInventory = PermissionService.hasPermission('inventory', user: currentUser);
      final hasPos = PermissionService.hasPermission('pos', user: currentUser);
      final hasCheckout = PermissionService.hasPermission('checkout', user: currentUser) || hasPos;
      final hasSales = PermissionService.hasPermission('sales', user: currentUser);
      final hasPurchases = PermissionService.hasPermission('purchases', user: currentUser);
      final hasExpenses = PermissionService.hasPermission('expenses', user: currentUser);
      final hasShifts = PermissionService.hasPermission('shifts', user: currentUser);
      final hasUtilities = PermissionService.hasPermission('utilities', user: currentUser);
      final hasActivity = PermissionService.hasPermission('activity', user: currentUser);
      final hasBackup = PermissionService.hasPermission('backup', user: currentUser);
      final hasSettings = PermissionService.hasPermission('settings', user: currentUser);

      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppTopBar(
          title: 'System Modules',
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
                if (hasAccounting || hasReports) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Accounting & Financial Engine',
                    icon: Icons.account_balance_outlined,
                    color: AppColors.primary,
                  ),
                  _buildGridSection([
                    if (hasAccounting) ...[
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
                    ],
                    if (hasReports)
                      _ModuleItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Sales & Business Reports',
                        route: '/reports',
                      ),
                    if (hasAccounting) ...[
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
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],

                // Cash & Banking Group
                if (hasCash || hasBank || hasCashBank || hasCheques || hasLoans) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Cash & Banking',
                    icon: Icons.account_balance_wallet_outlined,
                    color: isDark ? AppColors.info : const Color(0xFF0284C7),
                  ),
                  _buildGridSection([
                    if (hasCash)
                      _ModuleItem(
                        icon: Icons.payments_outlined,
                        label: 'Petty Cash',
                        route: '/cash',
                      ),
                    if (hasBank)
                      _ModuleItem(
                        icon: Icons.account_balance_rounded,
                        label: 'Bank Accounts',
                        route: '/bank',
                      ),
                    if (hasCashBank)
                      _ModuleItem(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Cash & Bank Ledger',
                        route: '/cash-bank',
                      ),
                    if (hasCheques)
                      _ModuleItem(
                        icon: Icons.payment_rounded,
                        label: 'Cheques Register',
                        route: '/cheques',
                      ),
                    if (hasLoans)
                      _ModuleItem(
                        icon: Icons.request_quote_outlined,
                        label: 'Loan Accounts',
                        route: '/loans',
                      ),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Parties & Contacts Group
                if (hasCustomers || hasSuppliers || hasTransporters) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Parties & Contacts',
                    icon: Icons.people_outline,
                    color: AppColors.primary,
                  ),
                  _buildGridSection([
                    if (hasCustomers)
                      _ModuleItem(
                        icon: Icons.person_rounded,
                        label: 'Customers',
                        route: '/customers',
                      ),
                    if (hasSuppliers)
                      _ModuleItem(
                        icon: Icons.storefront_rounded,
                        label: 'Suppliers & Vendors',
                        route: '/suppliers',
                      ),
                    if (hasTransporters)
                      _ModuleItem(
                        icon: Icons.local_shipping_rounded,
                        label: 'Transporters',
                        route: '/transporters',
                      ),
                    if (hasCustomers)
                      _ModuleItem(
                        icon: Icons.menu_book_rounded,
                        label: 'Digital Khaata',
                        route: '/khaata',
                      ),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Inventory & Product Catalog Group
                if (hasProducts || hasCategories || hasSubcategories || hasInventory) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Inventory & Product Catalog',
                    icon: Icons.inventory_2_outlined,
                    color: isDark ? AppColors.info : const Color(0xFF0284C7),
                  ),
                  _buildGridSection([
                    if (hasProducts)
                      _ModuleItem(
                        icon: Icons.inventory_rounded,
                        label: 'Products Catalog',
                        route: '/products',
                      ),
                    if (hasCategories)
                      _ModuleItem(
                        icon: Icons.category_rounded,
                        label: 'Categories',
                        route: '/categories',
                      ),
                    if (hasSubcategories)
                      _ModuleItem(
                        icon: Icons.alt_route_rounded,
                        label: 'Subcategories',
                        route: '/subcategories',
                      ),
                    if (hasInventory) ...[
                      _ModuleItem(
                        icon: Icons.warehouse_rounded,
                        label: 'Inventory & Stock Movements',
                        route: '/inventory',
                      ),
                      _ModuleItem(
                        icon: Icons.playlist_add_check_rounded,
                        label: 'Opening Stock Manager',
                        route: '/opening-stock',
                      ),
                      _ModuleItem(
                        icon: Icons.store_mall_directory_rounded,
                        label: 'Stores / Godowns',
                        route: '/inventory/godowns',
                      ),
                      _ModuleItem(
                        icon: Icons.sync_alt_rounded,
                        label: 'Stock Transfer',
                        route: '/inventory/stock-transfer',
                      ),
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],

                // Sales & POS Billing Group
                if (hasPos || hasCheckout || hasSales) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Sales & POS Billing',
                    icon: Icons.point_of_sale_rounded,
                    color: AppColors.primary,
                  ),
                  _buildGridSection([
                    if (hasPos)
                      _ModuleItem(
                        icon: Icons.point_of_sale_rounded,
                        label: 'POS Billing Terminal',
                        route: '/pos',
                      ),
                    if (hasCheckout)
                      _ModuleItem(
                        icon: Icons.shopping_cart_checkout_rounded,
                        label: 'POS Checkout Cart',
                        route: '/checkout',
                      ),
                    if (hasSales) ...[
                      _ModuleItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Sales Invoices',
                        route: '/sales',
                      ),
                      _ModuleItem(
                        icon: Icons.payments_rounded,
                        label: 'Payment-In Collection',
                        route: '/sales/payment-in',
                      ),
                      _ModuleItem(
                        icon: Icons.assignment_return_rounded,
                        label: 'Sale Returns (Credit Notes)',
                        route: '/sales/return',
                      ),
                    ],
                  ]),
                  const SizedBox(height: 16),
                ],

                // Purchases & Vendor Procurement Group
                if (hasPurchases) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Purchases & Vendor Procurement',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.primary,
                  ),
                  _buildGridSection([
                    _ModuleItem(
                      icon: Icons.shopping_bag_rounded,
                      label: 'Purchase Bills List',
                      route: '/purchases',
                    ),
                    _ModuleItem(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Create Purchase Bill',
                      route: '/purchases/create',
                    ),
                    _ModuleItem(
                      icon: Icons.upload_outlined,
                      label: 'Payment-Out Disbursements',
                      route: '/payment-out',
                    ),
                    _ModuleItem(
                      icon: Icons.assignment_return_outlined,
                      label: 'Purchase Returns (Debit Notes)',
                      route: '/purchase-return',
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Expenses & Indirect Income Group
                if (hasExpenses) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Expenses & Indirect Income',
                    icon: Icons.receipt_long_outlined,
                    color: isDark ? AppColors.warning : const Color(0xFFD97706),
                  ),
                  _buildGridSection([
                    _ModuleItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Expenses Manager',
                      route: '/expenses',
                    ),
                    _ModuleItem(
                      icon: Icons.trending_up_rounded,
                      label: 'Other Direct / Indirect Income',
                      route: '/expenses/income',
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],

                // Shift & Utility Tools Group
                if (hasShifts || hasUtilities) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Shift & Utility Tools',
                    icon: Icons.construction_outlined,
                    color: isDark ? AppColors.warning : const Color(0xFFD97706),
                  ),
                  _buildGridSection([
                    if (hasShifts)
                      _ModuleItem(
                        icon: Icons.schedule_rounded,
                        label: 'Cashier Shifts',
                        route: '/shifts',
                      ),
                    if (hasUtilities) ...[
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
                ],

                // Administration & Security Group
                if (hasActivity || hasBackup || hasSettings) ...[
                  _buildSectionHeader(
                    context: context,
                    title: 'Administration & Security',
                    icon: Icons.admin_panel_settings_outlined,
                    color: isDark ? AppColors.danger : const Color(0xFFE11D48),
                  ),
                  _buildGridSection([
                    if (hasActivity)
                      _ModuleItem(
                        icon: Icons.history_rounded,
                        label: 'Activity Audit Logs',
                        route: '/activity',
                      ),
                    if (hasBackup)
                      _ModuleItem(
                        icon: Icons.cloud_sync_rounded,
                        label: 'Backup & Restore',
                        route: '/backup',
                      ),
                    if (hasSettings)
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
    });
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
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDark
                          ? AppColors.primary.withAlpha(30)
                          : AppColors.primary.withAlpha(20),
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foregroundLight,
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
