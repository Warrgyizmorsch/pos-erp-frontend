import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../utils/app_snackbar.dart';

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
      AppSnackbar.error(
        'Your role (${user.role.toUpperCase()}) is not authorized to access this section.',
        title: 'Access Denied',
      );
      return const RouteSettings(name: Routes.dashboard);
    }

    return null;
  }
}
