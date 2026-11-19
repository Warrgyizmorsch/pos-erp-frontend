class AppRoles {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String accountant = 'accountant';
  static const String stockManager = 'stock_manager';
  static const String cashier = 'cashier';

  static String getLabel(String role) {
    switch (role) {
      case admin:
        return 'Administrator';
      case manager:
        return 'Store Manager';
      case accountant:
        return 'Senior Accountant';
      case stockManager:
        return 'Stock Manager';
      case cashier:
        return 'POS Cashier';
      default:
        return role.toUpperCase();
    }
  }
}
