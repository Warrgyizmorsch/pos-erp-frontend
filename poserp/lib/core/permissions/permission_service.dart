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
