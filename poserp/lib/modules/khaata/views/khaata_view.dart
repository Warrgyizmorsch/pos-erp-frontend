import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/khaata_controller.dart';
import '../widgets/khaata_payment_dialog.dart';

class KhaataView extends GetView<KhaataController> {
  const KhaataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Digital Khaata (Ledger)',
        subtitle: 'Manage customer udhaar and supplier payables directly synced with accounting',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: () => controller.loadBalances(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadBalances(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Metrics Cards
              Obx(() {
                final recStr = '₹${controller.totalReceivable.toStringAsFixed(2)}';
                final payStr = '₹${controller.totalPayable.toStringAsFixed(2)}';
                final netStr = '₹${controller.netOutstanding.abs().toStringAsFixed(2)} ${controller.netOutstanding >= 0 ? "(Rec)" : "(Pay)"}';

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Total Receivable',
                                value: recStr,
                                icon: Icons.arrow_downward_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Total Payable',
                                value: payStr,
                                icon: Icons.arrow_upward_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Net Balance',
                                value: netStr,
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Receivable (Udhaar)',
                            value: recStr,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Payable (Suppliers)',
                            value: payStr,
                            icon: Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Net Outstanding',
                            value: netStr,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),

              // 2. Search & Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            hintText: 'Search by party name or mobile number...',
                            onChanged: (val) => controller.searchQuery.value = val,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(
                        () => Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            _buildFilterChip('All Status', 'all', controller.statusFilter.value, (v) => controller.statusFilter.value = v),
                            const SizedBox(width: 6),
                            _buildFilterChip('Due Balances', 'due', controller.statusFilter.value, (v) => controller.statusFilter.value = v),
                            const SizedBox(width: 6),
                            _buildFilterChip('Settled (₹0)', 'settled', controller.statusFilter.value, (v) => controller.statusFilter.value = v),
                            const SizedBox(width: 16),
                            const Text(
                              'Party: ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            _buildFilterChip('All Parties', 'all', controller.partyTypeFilter.value, (v) => controller.partyTypeFilter.value = v),
                            const SizedBox(width: 6),
                            _buildFilterChip('Customers Only', 'customer', controller.partyTypeFilter.value, (v) => controller.partyTypeFilter.value = v),
                            const SizedBox(width: 6),
                            _buildFilterChip('Suppliers Only', 'supplier', controller.partyTypeFilter.value, (v) => controller.partyTypeFilter.value = v),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Parties List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: LoadingIndicator());
                }

                final list = controller.filteredParties;
                if (list.isEmpty) {
                  return const EmptyState(
                    title: 'No Khaata records found',
                    description: 'No customer or supplier matches your filter criteria.',
                    icon: Icons.menu_book_rounded,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final party = list[index];
                    final isReceivable = party.currentBalance > 0;
                    final isPayable = party.currentBalance < 0;

                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 650;

                          final detailsCol = Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isReceivable
                                    ? AppColors.success.withAlpha(25)
                                    : (isPayable ? AppColors.danger.withAlpha(25) : Colors.grey.withAlpha(25)),
                                child: Icon(
                                  isReceivable
                                      ? Icons.arrow_downward_rounded
                                      : (isPayable ? Icons.arrow_upward_rounded : Icons.check_circle_outline),
                                  color: isReceivable
                                      ? AppColors.success
                                      : (isPayable ? AppColors.danger : Colors.grey),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          party.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(20),
                                            borderRadius: AppRadius.full,
                                          ),
                                          child: Text(
                                            party.partyType.toUpperCase(),
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Phone: ${party.phone}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );

                          final balanceCol = Column(
                            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              Text(
                                isReceivable
                                    ? '₹${party.currentBalance.toStringAsFixed(2)}'
                                    : (isPayable
                                        ? '₹${party.currentBalance.abs().toStringAsFixed(2)}'
                                        : '₹0.00'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isReceivable
                                      ? AppColors.success
                                      : (isPayable ? AppColors.danger : Colors.grey),
                                ),
                              ),
                              Text(
                                isReceivable
                                    ? 'You will receive'
                                    : (isPayable ? 'You will give' : 'Settled'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isReceivable
                                      ? AppColors.success
                                      : (isPayable ? AppColors.danger : Colors.grey),
                                ),
                              ),
                            ],
                          );

                          final actionsRow = Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (party.currentBalance != 0)
                                AppButton(
                                  text: 'WhatsApp',
                                  icon: const Icon(Icons.chat_outlined, size: 14),
                                  variant: AppButtonVariant.outline,
                                  height: 32,
                                  onPressed: () => controller.sendWhatsAppReminder(party),
                                ),
                              AppButton(
                                text: 'Receive',
                                icon: const Icon(Icons.arrow_downward_rounded, size: 14),
                                variant: AppButtonVariant.secondary,
                                height: 32,
                                onPressed: () => KhaataPaymentDialog.show(context, party: party, type: 'payment_in'),
                              ),
                              AppButton(
                                text: 'Pay',
                                icon: const Icon(Icons.arrow_upward_rounded, size: 14),
                                variant: AppButtonVariant.outline,
                                height: 32,
                                onPressed: () => KhaataPaymentDialog.show(context, party: party, type: 'payment_out'),
                              ),
                            ],
                          );

                          if (isMobile) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: detailsCol),
                                    balanceCol,
                                  ],
                                ),
                                const Divider(height: 16),
                                actionsRow,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(flex: 5, child: detailsCol),
                              Expanded(flex: 2, child: balanceCol),
                              const SizedBox(width: 16),
                              actionsRow,
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentValue, ValueChanged<String> onSelected) {
    final isSelected = value == currentValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.full,
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withAlpha(80)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
