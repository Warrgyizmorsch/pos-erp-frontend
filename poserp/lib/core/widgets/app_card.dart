import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg =
        backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    final defaultBorder =
        border ??
        BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        );

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: AppRadius.lg,
        border: Border.fromBorderSide(defaultBorder),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: child,
    );
  }
}
