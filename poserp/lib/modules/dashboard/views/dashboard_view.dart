import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/more_modules_view.dart';
import '../../../../data/models/user.dart';
import '../../accounting/vouchers/views/voucher_list_view.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../cash_bank/views/cash_bank_list_view.dart';
import '../../expenses/views/expense_list_view.dart';
import '../../parties/customers/views/customer_list_view.dart';
import '../../parties/suppliers/views/supplier_list_view.dart';
import '../../pos/views/pos_view.dart';
import '../../products/inventory/views/inventory_view.dart';
import '../../products/views/product_list_view.dart';
import '../../purchases/views/purchase_list_view.dart';
import '../../sales/views/sale_list_view.dart';
import '../controllers/dashboard_controller.dart';
import 'widgets/accountant_dashboard_widget.dart';
import 'widgets/admin_dashboard_widget.dart';
import 'widgets/cashier_dashboard_widget.dart';
import 'widgets/stock_manager_dashboard_widget.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;
      final role = user?.role ?? AppRoles.admin;
      final tabs = _resolveTabs(user, role);
      final rawIndex = controller.activeBottomNavIndex.value;
      final safeNavIndex = rawIndex.clamp(0, tabs.length - 1);


      return Scaffold(
        appBar: safeNavIndex == 0
            ? AppTopBar(
                title: 'POS ERP',
                subtitle: 'Welcome back, ${user?.name ?? "User"}',
                showBackButton: false,
                userRole: role,
              )
            : null,
        body: SafeArea(
          child: IndexedStack(
            index: safeNavIndex,
            children: tabs.map((t) => t.view).toList(),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: safeNavIndex,
          items: tabs,
          onTap: (index) => controller.setBottomNavIndex(index),
        ),
      );
    });
  }

  List<BottomNavTabItem> _resolveTabs(User? user, String role) {
    bool hasPerm(String module) =>
        PermissionService.hasPermission(module, user: user);

    // 1. Dashboard is always Tab 0
    final List<BottomNavTabItem> tabs = [
      BottomNavTabItem(
        id: 'dashboard',
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        view: _buildRoleDashboard(role),
      ),
    ];

    // 2. Candidate tabs by role priorities
    final List<BottomNavTabItem> candidateTabs = [];

    switch (role.toLowerCase()) {
      case AppRoles.cashier:
        candidateTabs.addAll([
          const BottomNavTabItem(
            id: 'pos',
            label: 'POS',
            icon: Icons.point_of_sale_outlined,
            activeIcon: Icons.point_of_sale_rounded,
            view: POSView(),
            requiredModule: 'pos',
          ),
          const BottomNavTabItem(
            id: 'sales',
            label: 'Sales',
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart_rounded,
            view: SaleListView(),
            requiredModule: 'sales',
          ),
          const BottomNavTabItem(
            id: 'customers',
            label: 'Customers',
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            view: CustomerListView(),
            requiredModule: 'customers',
          ),
          const BottomNavTabItem(
            id: 'expenses',
            label: 'Expenses',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            view: ExpenseListView(),
            requiredModule: 'expenses',
          ),
        ]);
        break;

      case AppRoles.accountant:
        candidateTabs.addAll([
          const BottomNavTabItem(
            id: 'cash-bank',
            label: 'Cash & Bank',
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            view: CashBankListView(),
            requiredModule: 'cash-bank',
          ),
          const BottomNavTabItem(
            id: 'accounting',
            label: 'Vouchers',
            icon: Icons.receipt_outlined,
            activeIcon: Icons.receipt_rounded,
            view: VoucherListView(),
            requiredModule: 'accounting',
          ),
          const BottomNavTabItem(
            id: 'expenses',
            label: 'Expenses',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            view: ExpenseListView(),
            requiredModule: 'expenses',
          ),
          const BottomNavTabItem(
            id: 'customers',
            label: 'Customers',
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            view: CustomerListView(),
            requiredModule: 'customers',
          ),
        ]);
        break;

      case AppRoles.stockManager:
        candidateTabs.addAll([
          const BottomNavTabItem(
            id: 'inventory',
            label: 'Inventory',
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            view: InventoryView(),
            requiredModule: 'inventory',
          ),
          const BottomNavTabItem(
            id: 'purchases',
            label: 'Purchases',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            view: PurchaseListView(),
            requiredModule: 'purchases',
          ),
          const BottomNavTabItem(
            id: 'products',
            label: 'Products',
            icon: Icons.category_outlined,
            activeIcon: Icons.category_rounded,
            view: ProductListView(),
            requiredModule: 'products',
          ),
          const BottomNavTabItem(
            id: 'suppliers',
            label: 'Suppliers',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
            view: SupplierListView(),
            requiredModule: 'suppliers',
          ),
        ]);
        break;

      case AppRoles.manager:
      case AppRoles.admin:
      default:
        candidateTabs.addAll([
          const BottomNavTabItem(
            id: 'sales',
            label: 'Sales',
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart_rounded,
            view: SaleListView(),
            requiredModule: 'sales',
          ),
          const BottomNavTabItem(
            id: 'purchases',
            label: 'Purchases',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            view: PurchaseListView(),
            requiredModule: 'purchases',
          ),
          const BottomNavTabItem(
            id: 'inventory',
            label: 'Inventory',
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            view: InventoryView(),
            requiredModule: 'inventory',
          ),
          const BottomNavTabItem(
            id: 'customers',
            label: 'Parties',
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            view: CustomerListView(),
            requiredModule: 'customers',
          ),
        ]);
        break;
    }

    // 3. Filter candidate tabs strictly by active user permissions
    final int maxMiddleTabs = role.toLowerCase() == AppRoles.admin ? 4 : 3;
    int addedMiddleTabs = 0;
    for (final tab in candidateTabs) {
      if (tab.requiredModule == null || hasPerm(tab.requiredModule!)) {
        tabs.add(tab);
        addedMiddleTabs++;
      }
      if (addedMiddleTabs >= maxMiddleTabs) break;
    }

    // 4. "More" is always the final tab
    tabs.add(
      const BottomNavTabItem(
        id: 'more',
        label: 'More',
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        view: MoreModulesView(),
      ),
    );

    return tabs;
  }

  Widget _buildRoleDashboard(String role) {
    Widget content;
    switch (role.toLowerCase()) {
      case AppRoles.cashier:
        content = const CashierDashboardWidget();
        break;
      case AppRoles.stockManager:
        content = const StockManagerDashboardWidget();
        break;
      case AppRoles.accountant:
        content = const AccountantDashboardWidget();
        break;
      case AppRoles.manager:
      case AppRoles.admin:
      default:
        content = const AdminDashboardWidget();
        break;
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadDashboard(),
      child: content,
    );
  }
}
