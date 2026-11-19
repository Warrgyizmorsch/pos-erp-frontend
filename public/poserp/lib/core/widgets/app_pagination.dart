import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_button.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.secondaryDark.withValues(alpha: 0.3)
            : AppColors.secondaryLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page $currentPage of $totalPages',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForegroundLight,
            ),
          ),
          Row(
            children: [
              AppButton(
                text: 'Previous',
                variant: AppButtonVariant.outline,
                height: 32,
                isDisabled: currentPage <= 1,
                onPressed: () => onPageChanged(currentPage - 1),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Next',
                variant: AppButtonVariant.outline,
                height: 32,
                isDisabled: currentPage >= totalPages,
                onPressed: () => onPageChanged(currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
