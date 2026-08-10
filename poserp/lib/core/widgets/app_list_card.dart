import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_card.dart';
import 'app_status_chip.dart';

class AppListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final String? statusText;
  final AppStatusChipType? statusType;
  final IconData? leadIcon;
  final VoidCallback? onTap;
  final Widget? popupMenu;

  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.statusText,
    this.statusType,
    this.leadIcon,
    this.onTap,
    this.popupMenu,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (leadIcon != null) ...[
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withAlpha(25),
                child: Icon(leadIcon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (statusText != null && statusText!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        AppStatusChip(
                          label: statusText!,
                          type: statusType ?? AppStatusChipType.info,
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null && trailingText!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                trailingText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            popupMenu ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
