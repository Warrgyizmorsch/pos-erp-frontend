import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

enum AppStatusChipType { success, warning, danger, info }

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusChipType type;

  const AppStatusChip({
    super.key,
    required this.label,
    this.type = AppStatusChipType.info,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case AppStatusChipType.success:
        bg = AppColors.success.withAlpha(25);
        fg = AppColors.success;
        break;
      case AppStatusChipType.warning:
        bg = AppColors.warning.withAlpha(25);
        fg = AppColors.warning;
        break;
      case AppStatusChipType.danger:
        bg = AppColors.danger.withAlpha(25);
        fg = AppColors.danger;
        break;
      case AppStatusChipType.info:
        bg = AppColors.primary.withAlpha(25);
        fg = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
