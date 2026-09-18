import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show({
    required String title,
    required String message,
    bool isError = false,
    Color? backgroundColor,
    Color? colorText,
    Duration duration = const Duration(seconds: 3),
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.hideCurrentSnackBar();
    state.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor:
            backgroundColor ?? (isError ? AppColors.danger : AppColors.success),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void error(String message, {String title = 'Error'}) {
    show(
      title: title,
      message: message,
      isError: true,
      backgroundColor: AppColors.danger,
      duration: const Duration(seconds: 4),
    );
  }

  static void success(String message, {String title = 'Success'}) {
    show(
      title: title,
      message: message,
      isError: false,
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
    );
  }

  static void info(String message, {String title = 'Info'}) {
    show(
      title: title,
      message: message,
      isError: false,
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 3),
    );
  }
}
