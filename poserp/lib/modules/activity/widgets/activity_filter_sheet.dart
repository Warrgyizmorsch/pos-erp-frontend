import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/activity_log_controller.dart';

class ActivityFilterSheet extends StatefulWidget {
  final ActivityLogController controller;

  const ActivityFilterSheet({super.key, required this.controller});

  static void show(BuildContext context, ActivityLogController controller) {
    Get.bottomSheet(
      ActivityFilterSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<ActivityFilterSheet> {
  late String _tempModule;
  late String _tempAction;
  late String _tempStartDate;
  late String _tempEndDate;
  late TextEditingController _userController;

  final List<String> _modules = [
    'all',
    'Product',
    'Category',
    'Subcategory',
    'Customer',
    'Supplier',
    'Transporter',
    'Expense',
    'Shift',
    'Sale',
    'Purchase',
    'Auth',
    'Inventory',
    'CashBank',
  ];

  final List<String> _actions = [
    'all',
    'create',
    'update',
    'delete',
    'login',
    'logout',
    'stock_adjust',
    'sale',
    'purchase',
    'cancel',
  ];

  @override
  void initState() {
    super.initState();
    _tempModule = widget.controller.selectedModule.value;
    _tempAction = widget.controller.selectedAction.value;
    _tempStartDate = widget.controller.startDate.value;
    _tempEndDate = widget.controller.endDate.value;
    _userController =
        TextEditingController(text: widget.controller.searchUser.value);
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  void _pickDatePreset(String preset) {
    final now = DateTime.now();
    String start = '';
    String end = '';

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    switch (preset) {
      case 'today':
        start = fmt(now);
        end = fmt(now);
        break;
      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        start = fmt(y);
        end = fmt(y);
        break;
      case 'last7':
        final s = now.subtract(const Duration(days: 6));
        start = fmt(s);
        end = fmt(now);
        break;
      case 'thisMonth':
        final s = DateTime(now.year, now.month, 1);
        start = fmt(s);
        end = fmt(now);
        break;
      case 'clear':
        start = '';
        end = '';
        break;
    }

    setState(() {
      _tempStartDate = start;
      _tempEndDate = end;
    });
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _tempStartDate.isNotEmpty && _tempEndDate.isNotEmpty
          ? DateTimeRange(
              start: DateTime.tryParse(_tempStartDate) ?? now,
              end: DateTime.tryParse(_tempEndDate) ?? now,
            )
          : null,
    );

    if (picked != null) {
      String fmt(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      setState(() {
        _tempStartDate = fmt(picked.start);
        _tempEndDate = fmt(picked.end);
      });
    }
  }

  void _apply() {
    widget.controller.searchUser.value = _userController.text.trim();
    widget.controller.selectedModule.value = _tempModule;
    widget.controller.selectedAction.value = _tempAction;
    widget.controller.startDate.value = _tempStartDate;
    widget.controller.endDate.value = _tempEndDate;
    widget.controller.selectedQuickFilter.value = 'custom';
    widget.controller.currentPage.value = 1;
    widget.controller.loadLogs();
    Get.back();
  }

  void _reset() {
    setState(() {
      _tempModule = 'all';
      _tempAction = 'all';
      _tempStartDate = '';
      _tempEndDate = '';
      _userController.clear();
    });
    widget.controller.clearFilters();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter Activity Logs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Filter Options Body (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Search Field
                    const Text(
                      'User Name / Keyword',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _userController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Admin, cashier...',
                        prefixIcon: const Icon(Icons.person_search_outlined,
                            size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Date Range Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Date Range',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_tempStartDate.isNotEmpty ||
                            _tempEndDate.isNotEmpty)
                          GestureDetector(
                            onTap: () => _pickDatePreset('clear'),
                            child: const Text(
                              'Clear Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick presets chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Today', 'today'),
                        _buildPresetChip('Yesterday', 'yesterday'),
                        _buildPresetChip('Last 7 Days', 'last7'),
                        _buildPresetChip('This Month', 'thisMonth'),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Date Range Display & Custom Picker Button
                    InkWell(
                      onTap: _pickCustomDateRange,
                      borderRadius: AppRadius.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.inputDark
                              : Colors.grey[100],
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: _tempStartDate.isNotEmpty
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: _tempStartDate.isNotEmpty
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _tempStartDate.isNotEmpty &&
                                        _tempEndDate.isNotEmpty
                                    ? '$_tempStartDate  →  $_tempEndDate'
                                    : 'Select Custom Date Range',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _tempStartDate.isNotEmpty
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _tempStartDate.isNotEmpty
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Module Dropdown
                    const Text(
                      'Module',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _tempModule,
                      dropdownColor: isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                      items: _modules.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(
                            m == 'all' ? 'All Modules' : m,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _tempModule = val);
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    // Action Dropdown
                    const Text(
                      'Action Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _tempAction,
                      dropdownColor: isDark
                          ? AppColors.cardDark
                          : AppColors.cardLight,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                      items: _actions.map((a) {
                        return DropdownMenuItem(
                          value: a,
                          child: Text(
                            a == 'all'
                                ? 'All Actions'
                                : a.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _tempAction = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Reset All',
                      variant: AppButtonVariant.outline,
                      onPressed: _reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: 'Apply Filters',
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String preset) {
    final now = DateTime.now();
    String start = '';
    String end = '';
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    switch (preset) {
      case 'today':
        start = fmt(now);
        end = fmt(now);
        break;
      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        start = fmt(y);
        end = fmt(y);
        break;
      case 'last7':
        final s = now.subtract(const Duration(days: 6));
        start = fmt(s);
        end = fmt(now);
        break;
      case 'thisMonth':
        final s = DateTime(now.year, now.month, 1);
        start = fmt(s);
        end = fmt(now);
        break;
    }

    final isSelected = _tempStartDate == start && _tempEndDate == end;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => _pickDatePreset(preset),
      selectedColor: AppColors.primary.withAlpha(30),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
