import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../constants/app_roles.dart';

class PermissionService {
  static const List<String> allRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.accountant,
    AppRoles.stockManager,
    AppRoles.cashier,
  ];

  static const List<String> partiesRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.cashier,
  ];

  static const List<String> inventoryRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.stockManager,
  ];

  static const List<String> salesRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.cashier,
  ];

  static const List<String> purchaseRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.stockManager,
  ];

  static const List<String> cashBankRoles = [
    AppRoles.admin,
    AppRoles.accountant,
  ];

  static const List<String> expenseRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.accountant,
  ];

  static const List<String> accountingRoles = [
    AppRoles.admin,
    AppRoles.accountant,
  ];

  static const List<String> reportsRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.accountant,
  ];

  static const List<String> shiftRoles = [
    AppRoles.admin,
    AppRoles.manager,
    AppRoles.cashier,
  ];

  static const List<String> adminOnlyRoles = [AppRoles.admin];

  static const List<String> utilityRoles = [AppRoles.admin, AppRoles.manager];

  /// Standard system baseline permissions for each role
  static const Map<String, List<String>> roleDefaultModules = {
    'admin': [
      'dashboard', 'sales', 'purchases', 'inventory', 'products', 'categories',
      'subcategories', 'customers', 'suppliers', 'accounting', 'bank', 'cash',
      'cash-bank', 'expenses', 'loans', 'cheques', 'reports', 'settings', 'pos',
      'activity', 'shifts', 'backup', 'transporters', 'utilities', 'checkout',
      'marketing', 'integrations'
    ],
    'manager': [
      'dashboard', 'sales', 'purchases', 'inventory', 'products', 'categories',
      'subcategories', 'customers', 'suppliers', 'expenses', 'reports', 'settings',
      'pos', 'activity', 'shifts', 'transporters', 'utilities', 'checkout'
    ],
    'accountant': [
      'dashboard', 'accounting', 'bank', 'cash', 'cash-bank', 'expenses',
      'loans', 'cheques', 'reports'
    ],
    'stock_manager': [
      'dashboard', 'inventory', 'products', 'categories', 'subcategories',
      'purchases', 'suppliers', 'transporters', 'utilities'
    ],
    'cashier': [
      'dashboard', 'pos', 'sales', 'shifts', 'checkout', 'customers'
    ],
  };

  /// Evaluates whether a user is authorized for a specific module
  static bool hasPermission(String module, {User? user}) {
    if (user == null && Get.isRegistered<AuthController>()) {
      user = Get.find<AuthController>().currentUser.value;
    }
    if (user == null) return false;

    // 1. Admin always has full access to everything
    if (user.role.toLowerCase() == AppRoles.admin || user.role.toLowerCase() == 'admin') {
      return true;
    }

    // 2. Fine-grained custom permissions assigned specifically to user
    if (user.permissions.isNotEmpty) {
      return user.permissions.contains(module);
    }

    // 3. Fallback to standard role defaults if custom array is empty
    final defaults = roleDefaultModules[user.role.toLowerCase()] ?? [];
    return defaults.contains(module);
  }

  /// Evaluates whether user has access to at least one module in a list
  static bool hasAnyPermission(List<String> modules, {User? user}) {
    return modules.any((m) => hasPermission(m, user: user));
  }

  static bool hasRole(String userRole, List<String> allowedRoles) {
    return allowedRoles.contains(userRole);
  }

  static bool canDelete(String userRole, String module) {
    if (userRole == AppRoles.admin) return true;
    if (userRole == AppRoles.manager &&
        [
          'sales',
          'purchases',
          'products',
          'customers',
          'suppliers',
        ].contains(module)) {
      return true;
    }
    return false;
  }
}
