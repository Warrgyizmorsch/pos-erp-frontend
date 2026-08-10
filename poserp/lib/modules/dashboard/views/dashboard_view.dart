import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/more_modules_view.dart';
import '../../parties/customers/views/customer_list_view.dart';
import '../../products/inventory/views/inventory_view.dart';
import '../../purchases/views/purchase_list_view.dart';
import '../../sales/views/sale_list_view.dart';
import '../../authentication/controllers/auth_controller.dart';
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
      final navIndex = controller.activeBottomNavIndex.value;

      return Scaffold(
        appBar: navIndex == 5
            ? null
            : AppTopBar(
                title: 'POS ERP',
                subtitle: 'Welcome back, ${user?.name ?? "User"}',
                showBackButton: false,
                userRole: role,
              ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.loadDashboard(),
            child: IndexedStack(
              index: navIndex,
              children: [
                // Tab 0: Role-Specific Executive Dashboard
                _buildRoleDashboard(role),

                // Tab 1: Sales Invoices
                const SaleListView(),

                // Tab 2: Purchase Bills
                const PurchaseListView(),

                // Tab 3: Inventory Manager
                const InventoryView(),

                // Tab 4: Customers & Parties
                const CustomerListView(),

                // Tab 5: More System Modules Full Screen View
                const MoreModulesView(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: navIndex,
          onTap: (index) => controller.setBottomNavIndex(index),
        ),
      );
    });
  }

  Widget _buildRoleDashboard(String role) {
    switch (role) {
      case AppRoles.cashier:
        return const CashierDashboardWidget();
      case AppRoles.stockManager:
        return const StockManagerDashboardWidget();
      case AppRoles.accountant:
        return const AccountantDashboardWidget();
      case AppRoles.manager:
      case AppRoles.admin:
      default:
        return const AdminDashboardWidget();
    }
  }
}
