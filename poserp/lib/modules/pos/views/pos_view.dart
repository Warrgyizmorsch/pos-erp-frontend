import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_item_table.dart';
import '../widgets/pos_right_panel.dart';

class POSView extends StatefulWidget {
  const POSView({super.key});

  @override
  State<POSView> createState() => _POSViewState();
}

class _POSViewState extends State<POSView> {
  int _mobileTabIndex = 0; // 0 for Cart, 1 for Pay

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Cashier Interface'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          // Multi-bill Tabs Header
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...controller.bills.map((bill) {
                    final isActive = controller.activeBillId.value == bill.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ActionChip(
                        avatar: Icon(
                          Icons.receipt,
                          size: 14,
                          color: isActive ? Colors.white : AppColors.primary,
                        ),
                        label: Text(
                          'Bill #${bill.billNo}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.white
                                : (isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foregroundLight),
                          ),
                        ),
                        backgroundColor: isActive
                            ? AppColors.primary
                            : (isDark ? AppColors.cardDark : Colors.grey[200]),
                        onPressed: () => controller.setActiveBill(bill.id),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Create New Bill Tab',
                    onPressed: () => controller.createNewBill(),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          if (isDesktop) {
            // 60/40 Split Desktop Layout
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 60% Cart & Items Table
                  Expanded(flex: 6, child: POSItemTable()),
                  SizedBox(width: 16),
                  // 40% Billing & Checkout Panel
                  Expanded(flex: 4, child: POSRightPanel()),
                ],
              ),
            );
          }

          // Mobile / Tablet Tabbed View (< 1024dp)
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _mobileTabIndex == 0
                      ? const POSItemTable()
                      : const POSRightPanel(),
                ),
              ),
              // Bottom Navigation Bar
              BottomNavigationBar(
                currentIndex: _mobileTabIndex,
                selectedItemColor: AppColors.primary,
                onTap: (index) => setState(() => _mobileTabIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: 'Cart & Items',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet),
                    label: 'Pay & Checkout',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
