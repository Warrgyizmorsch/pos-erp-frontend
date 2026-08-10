import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../constants/app_colors.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware(this.allowedRoles);

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: Routes.login);
    }

    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (!authController.isAuthenticated || user == null) {
      return const RouteSettings(name: Routes.login);
    }

    if (!allowedRoles.contains(user.role)) {
      Future.microtask(() {
        Get.snackbar(
          'Access Denied',
          'Your role (${user.role.toUpperCase()}) is not authorized to access this section.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        );
      });
      return const RouteSettings(name: Routes.dashboard);
    }

    return null;
  }
}
