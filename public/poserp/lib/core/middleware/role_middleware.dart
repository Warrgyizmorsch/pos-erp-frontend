import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../permissions/permission_service.dart';
import '../utils/app_snackbar.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String>? allowedRoles;
  final String? module;
  final List<String>? allowedModules;

  RoleMiddleware(this.allowedRoles, {this.module, this.allowedModules});

  factory RoleMiddleware.module(String module) =>
      RoleMiddleware(null, module: module);

  factory RoleMiddleware.anyModule(List<String> modules) =>
      RoleMiddleware(null, allowedModules: modules);

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

    // Admin always bypasses all role/module restrictions
    if (user.role.toLowerCase() == 'admin') {
      return null;
    }

    // 1. Direct single-module permission check
    if (module != null && module!.isNotEmpty) {
      if (!PermissionService.hasPermission(module!, user: user)) {
        AppSnackbar.error(
          'You are not authorized to access the $module module.',
          title: 'Access Denied',
        );
        return const RouteSettings(name: Routes.dashboard);
      }
      return null;
    }

    // 2. Multi-module permission check
    if (allowedModules != null && allowedModules!.isNotEmpty) {
      if (!PermissionService.hasAnyPermission(allowedModules!, user: user)) {
        AppSnackbar.error(
          'You do not have permission to access this section.',
          title: 'Access Denied',
        );
        return const RouteSettings(name: Routes.dashboard);
      }
      return null;
    }

    // 3. Fallback to allowedRoles list
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      if (!allowedRoles!.contains(user.role)) {
        AppSnackbar.error(
          'Your role (${user.role.toUpperCase()}) is not authorized to access this section.',
          title: 'Access Denied',
        );
        return const RouteSettings(name: Routes.dashboard);
      }
    }

    return null;
  }
}
