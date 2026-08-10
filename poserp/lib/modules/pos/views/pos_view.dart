import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../controllers/pos_controller.dart';
import '../widgets/pos_item_table.dart';
import '../widgets/pos_right_panel.dart';

class POSView extends StatefulWidget {
  const POSView({super.key});

  @override
  State<POSView> createState() => _POSViewState();
}

class _POSViewState extends State<POSView> {
  int _mobileTabIndex = 0; // 0 for Cart & Items, 1 for Pay & Checkout

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'POS Terminal',
        subtitle: 'Fast billing & multi-order tabs',
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
                          Icons.receipt_rounded,
                          size: 16,
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
                      Icons.add_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    tooltip: 'Create New Bill Tab',
                    onPressed: () => controller.createNewBill(),
                  ),
                  const SizedBox(width: 8),
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

          // Mobile / Tablet View (<1024dp)
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
              // Mobile Quick Summary Bar when on Cart Tab
              if (_mobileTabIndex == 0)
                Obx(() {
                  final bill = controller.activeBill;
                  final total = bill?.grandTotal ?? 0.0;
                  final count = bill?.totalItems ?? 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$count ITEMS IN CART',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, AppSizes.minTouchTarget),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                          ),
                          label: const Text(
                            'Checkout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => setState(() => _mobileTabIndex = 1),
                        ),
                      ],
                    ),
                  );
                }),
              // Mobile Bottom Navigation Bar
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
                    icon: Icon(Icons.payment_outlined),
                    activeIcon: Icon(Icons.payment_rounded),
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
