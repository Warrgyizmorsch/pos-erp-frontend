import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../models/product.dart';
import '../controllers/godown_controller.dart';

class _TransferItemRow {
  Product? product;
  final TextEditingController qtyCtrl = TextEditingController(text: '1');

  double get quantity => double.tryParse(qtyCtrl.text) ?? 1.0;

  void dispose() {
    qtyCtrl.dispose();
  }
}

class StockTransferView extends StatefulWidget {
  const StockTransferView({super.key});

  @override
  State<StockTransferView> createState() => _StockTransferViewState();
}

class _StockTransferViewState extends State<StockTransferView> {
  final GodownController controller = Get.find<GodownController>();
  final ApiClient apiClient = Get.find<ApiClient>();

  final List<Product> availableProducts = [];
  final List<_TransferItemRow> transferItems = [];
  final TextEditingController notesCtrl = TextEditingController();

  String? sourceGodownId;
  String? destinationGodownId;
  bool isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _addItem();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoadingProducts = true);
    try {
      final res = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'limit': 200},
      );
      final body = res.data as Map<String, dynamic>;
      final list = body['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          availableProducts.assignAll(
            list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
          );
        });
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() => isLoadingProducts = false);
      }
    }
  }

  @override
  void dispose() {
    for (final it in transferItems) {
      it.dispose();
    }
    notesCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      transferItems.add(_TransferItemRow());
    });
  }

  void _removeItem(int index) {
    if (transferItems.length <= 1) return;
    setState(() {
      final it = transferItems.removeAt(index);
      it.dispose();
    });
  }

  Future<void> _submit() async {
    if (sourceGodownId == null || destinationGodownId == null) {
      Get.snackbar('Error', 'Please select source and destination godowns', backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    final validItems = transferItems.where((it) => it.product != null && it.quantity > 0).toList();
    if (validItems.isEmpty) {
      Get.snackbar('Error', 'Please add at least one product with quantity > 0', backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    final payloadItems = validItems.map((it) => {
      'productId': it.product!.id,
      'quantity': it.quantity,
    }).toList();

    final success = await controller.transferStock(
      sourceGodownId: sourceGodownId!,
      destinationGodownId: destinationGodownId!,
      items: payloadItems,
      notes: notesCtrl.text.trim(),
    );

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Stock Transfer',
        subtitle: 'Reallocate inventory stock between store locations',
        actions: [
          Obx(
            () => AppButton(
              text: 'Complete Transfer',
              icon: const Icon(Icons.check_rounded, size: 16),
              variant: AppButtonVariant.primary,
              height: 38,
              isLoading: controller.isSubmitting.value,
              onPressed: _submit,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Source & Destination Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GODOWN LOCATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 650;

                      final sourceField = Obx(() {
                        final godowns = controller.godowns;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Source Godown (From) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: sourceGodownId,
                              hint: const Text('Select Origin Store', style: TextStyle(fontSize: 13)),
                              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: AppRadius.md),
                              ),
                              items: godowns.map((g) => DropdownMenuItem<String>(
                                value: g.id,
                                child: Text('${g.name} (${g.code})', style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              onChanged: (id) => setState(() => sourceGodownId = id),
                            ),
                          ],
                        );
                      });

                      final destField = Obx(() {
                        final godowns = controller.godowns;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destination Godown (To) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: destinationGodownId,
                              hint: const Text('Select Target Store', style: TextStyle(fontSize: 13)),
                              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: AppRadius.md),
                              ),
                              items: godowns.map((g) => DropdownMenuItem<String>(
                                value: g.id,
                                child: Text('${g.name} (${g.code})', style: const TextStyle(fontSize: 13)),
                              )).toList(),
                              onChanged: (id) => setState(() => destinationGodownId = id),
                            ),
                          ],
                        );
                      });

                      if (isMobile) {
                        return Column(
                          children: [
                            sourceField,
                            const SizedBox(height: 12),
                            destField,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: sourceField),
                          const SizedBox(width: 16),
                          Expanded(child: destField),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Transfer Items Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PRODUCTS TO TRANSFER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      AppButton(
                        text: 'Add Product',
                        icon: const Icon(Icons.add, size: 16),
                        variant: AppButtonVariant.outline,
                        height: 32,
                        onPressed: _addItem,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...transferItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : Colors.grey[50],
                        borderRadius: AppRadius.md,
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary.withAlpha(30),
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: item.product?.id,
                              hint: const Text('Select Product to Transfer...', style: TextStyle(fontSize: 12)),
                              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: AppRadius.sm),
                              ),
                              items: availableProducts.map((p) => DropdownMenuItem<String>(
                                value: p.id,
                                child: Text('${p.name} (Stock: ${p.stock.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (pId) {
                                final p = availableProducts.firstWhereOrNull((x) => x.id == pId);
                                if (p != null) {
                                  setState(() {
                                    item.product = p;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              controller: item.qtyCtrl,
                              label: 'Transfer Qty',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          if (transferItems.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: notesCtrl,
                    label: 'Transfer Notes & Dispatch Reference',
                    hintText: 'e.g. Internal store transfer, vehicle number, authorization reference',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
