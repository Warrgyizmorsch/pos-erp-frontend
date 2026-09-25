import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../models/product.dart';
import '../controllers/godown_controller.dart';
import '../models/godown.dart';

class _TransferItemRow {
  Product? product;
  final TextEditingController qtyCtrl;

  _TransferItemRow({double initialQty = 1})
      : qtyCtrl = TextEditingController(
          text: initialQty % 1 == 0
              ? initialQty.toInt().toString()
              : initialQty.toString(),
        );

  double get quantity => double.tryParse(qtyCtrl.text) ?? 0.0;

  void increment([double step = 1]) {
    final cur = quantity;
    final next = cur + step;
    qtyCtrl.text = next % 1 == 0 ? next.toInt().toString() : next.toString();
  }

  void decrement([double step = 1]) {
    final cur = quantity;
    if (cur > step) {
      final next = cur - step;
      qtyCtrl.text = next % 1 == 0 ? next.toInt().toString() : next.toString();
    } else {
      qtyCtrl.text = '1';
    }
  }

  void setMaxStock() {
    if (product != null && product!.stock > 0) {
      final s = product!.stock;
      qtyCtrl.text = s % 1 == 0 ? s.toInt().toString() : s.toString();
    }
  }

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
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _addItem();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    if (!isLoadingProducts && mounted) {
      setState(() => isLoadingProducts = true);
    }
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

  void _swapGodowns() {
    setState(() {
      final temp = sourceGodownId;
      sourceGodownId = destinationGodownId;
      destinationGodownId = temp;
    });
  }

  int get _selectedProductCount =>
      transferItems.where((it) => it.product != null).length;

  double get _totalTransferUnits => transferItems
      .where((it) => it.product != null && it.quantity > 0)
      .fold(0.0, (sum, it) => sum + it.quantity);

  Godown? _getGodown(String? id) =>
      controller.godowns.firstWhereOrNull((g) => g.id == id);

  void _openProductPicker(_TransferItemRow item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductPickerSheet(
        products: availableProducts,
        selectedProductId: item.product?.id,
        onSelect: (p) {
          setState(() {
            item.product = p;
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (sourceGodownId == null || destinationGodownId == null) {
      AppSnackbar.error('Please select both source and destination godowns');
      return;
    }

    if (sourceGodownId == destinationGodownId) {
      AppSnackbar.error('Source and destination godowns cannot be the same store');
      return;
    }

    final validItems = transferItems
        .where((it) => it.product != null && it.quantity > 0)
        .toList();
    if (validItems.isEmpty) {
      AppSnackbar.error('Please add at least one product with quantity > 0');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Stock Transfer',
        subtitle: 'Reallocate inventory stock between store locations',
      ),
      bottomNavigationBar: _buildStickyBottomBar(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Source & Destination Store Router Card
            _buildStoreRoutingCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 2. Transfer Items Card
            _buildTransferItemsCard(isDark, isMobile),
            const SizedBox(height: 16),

            // 3. Notes & Dispatch Reference Card
            _buildNotesCard(isDark),
            const SizedBox(height: 16),

            // 4. Live Transfer Summary Card
            _buildSummaryCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreRoutingCard(bool isDark, bool isMobile) {
    final isSameStore = sourceGodownId != null &&
        destinationGodownId != null &&
        sourceGodownId == destinationGodownId;

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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: AppRadius.sm,
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'STORE ROUTING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (sourceGodownId != null || destinationGodownId != null)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Swap', style: TextStyle(fontSize: 12)),
                  onPressed: _swapGodowns,
                ),
            ],
          ),
          const SizedBox(height: 14),

          Obx(() {
            final godowns = controller.godowns;

            if (controller.isLoading.value && godowns.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (godowns.length < 2) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(25),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: Colors.amber.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'At least 2 active godowns/stores are required to transfer inventory.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            final sourceDropdown = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warehouse_outlined, size: 15, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Origin Store (From) *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: sourceGodownId,
                  hint: const Text('Select Origin Store',
                      style: TextStyle(fontSize: 13)),
                  dropdownColor:
                      isDark ? AppColors.cardDark : AppColors.cardLight,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.inputDark : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: AppRadius.md),
                  ),
                  items: godowns.map((g) {
                    return DropdownMenuItem<String>(
                      value: g.id,
                      child: Text(
                        '${g.name} (${g.code})',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) => setState(() => sourceGodownId = id),
                ),
              ],
            );

            final destDropdown = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 15, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Target Store (To) *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: destinationGodownId,
                  hint: const Text('Select Target Store',
                      style: TextStyle(fontSize: 13)),
                  dropdownColor:
                      isDark ? AppColors.cardDark : AppColors.cardLight,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.inputDark : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: AppRadius.md),
                  ),
                  items: godowns.map((g) {
                    return DropdownMenuItem<String>(
                      value: g.id,
                      child: Text(
                        '${g.name} (${g.code})',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (id) => setState(() => destinationGodownId = id),
                ),
              ],
            );

            if (isMobile) {
              return Column(
                children: [
                  sourceDropdown,
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  destDropdown,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: sourceDropdown),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Expanded(child: destDropdown),
              ],
            );
          }),

          if (isSameStore) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                borderRadius: AppRadius.sm,
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                  SizedBox(width: 6),
                  Text(
                    'Origin and destination stores cannot be the same.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransferItemsCard(bool isDark, bool isMobile) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: AppRadius.sm,
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'PRODUCTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : Colors.grey[200],
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        '${transferItems.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Add Product',
                icon: const Icon(Icons.add, size: 16),
                variant: AppButtonVariant.outline,
                height: 32,
                onPressed: _addItem,
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (isLoadingProducts)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            ...transferItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(item, index, isDark, isMobile);
            }),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    _TransferItemRow item,
    int index,
    bool isDark,
    bool isMobile,
  ) {
    final p = item.product;
    final isOverStock = p != null && item.quantity > p.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputDark : Colors.grey[50],
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isOverStock
              ? Colors.amber.shade700
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Item # and Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p != null ? 'Item #${index + 1}' : 'Select Item #${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              if (transferItems.length > 1)
                InkWell(
                  onTap: () => _removeItem(index),
                  borderRadius: AppRadius.sm,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Product Selector Box
          InkWell(
            onTap: () => _openProductPicker(item),
            borderRadius: AppRadius.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: AppRadius.md,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: p != null ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p?.name ?? 'Tap to select a product...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: p != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: p != null
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (p != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'SKU: ${p.sku}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: (p.stock > 0
                                          ? Colors.green
                                          : Colors.red)
                                      .withAlpha(20),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Text(
                                  'Current Stock: ${p.stock.toStringAsFixed(0)} ${p.unit}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: p.stock > 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Quantity Controls & Quick Steppers
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text(
                'Transfer Qty:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),

              // Stepper Controls
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => item.decrement());
                      },
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    Container(
                      width: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: item.qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => item.increment());
                      },
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: Icon(Icons.add, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick preset chips (+5, +10, Max)
              if (p != null) ...[
                _buildQuickQtyChip('+5', () {
                  setState(() => item.increment(5));
                }),
                _buildQuickQtyChip('+10', () {
                  setState(() => item.increment(10));
                }),
                if (p.stock > 0)
                  _buildQuickQtyChip('Max', () {
                    setState(() => item.setMaxStock());
                  }),
              ],
            ],
          ),

          // Overstock Warning Badge
          if (isOverStock) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Quantity (${item.quantity.toStringAsFixed(0)}) exceeds system stock (${p.stock.toStringAsFixed(0)}).',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickQtyChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: AppRadius.sm,
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'DISPATCH REFERENCE & NOTES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesCtrl,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'e.g. Internal store transfer, vehicle number, dispatch driver reference...',
              filled: true,
              fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: AppRadius.md),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    final src = _getGodown(sourceGodownId);
    final dst = _getGodown(destinationGodownId);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRANSFER OVERVIEW',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  'Products',
                  '$_selectedProductCount of ${transferItems.length}',
                  Icons.category_outlined,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              Expanded(
                child: _buildSummaryMetric(
                  'Total Volume',
                  '${_totalTransferUnits.toStringAsFixed(0)} units',
                  Icons.all_inbox_rounded,
                  isDark,
                ),
              ),
            ],
          ),
          if (src != null && dst != null) ...[
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.route_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${src.name}  ➔  ${dst.name}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedProductCount items selected',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${_totalTransferUnits.toStringAsFixed(0)} units total',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => AppButton(
                text: 'Complete Transfer',
                icon: const Icon(Icons.check_rounded, size: 18),
                variant: AppButtonVariant.primary,
                isLoading: controller.isSubmitting.value,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final String? selectedProductId;
  final ValueChanged<Product> onSelect;

  const _ProductPickerSheet({
    required this.products,
    this.selectedProductId,
    required this.onSelect,
  });

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = widget.products.where((p) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          (p.barcode != null && p.barcode!.toLowerCase().contains(q));
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: AppRadius.full,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search product name, SKU, barcode...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(borderRadius: AppRadius.md),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No products found matching search',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final isSelected = p.id == widget.selectedProductId;

                      return ListTile(
                        onTap: () {
                          widget.onSelect(p);
                          Navigator.pop(context);
                        },
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withAlpha(20),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'SKU: ${p.sku} • Stock: ${p.stock.toStringAsFixed(0)} ${p.unit}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
