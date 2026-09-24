import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/role.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/storage_service.dart';

class UserManagementController extends GetxController {
  final AuthRepository _authRepository;
  final StorageService _storageService;

  UserManagementController(this._authRepository, this._storageService);

  static const List<String> allModules = [
    'dashboard',
    'sales',
    'purchases',
    'inventory',
    'products',
    'categories',
    'subcategories',
    'customers',
    'suppliers',
    'accounting',
    'bank',
    'cash',
    'cash-bank',
    'expenses',
    'loans',
    'cheques',
    'reports',
    'settings',
    'pos',
    'activity',
    'shifts',
    'backup',
    'transporters',
    'utilities',
    'checkout',
  ];

  static const Map<String, List<String>> moduleCategories = {
    'Sales & POS': ['pos', 'sales', 'checkout', 'shifts'],
    'Inventory & Catalog': ['inventory', 'products', 'categories', 'subcategories'],
    'Parties & Vendors': ['purchases', 'customers', 'suppliers', 'transporters'],
    'Financials & Cash/Bank': [
      'accounting',
      'bank',
      'cash',
      'cash-bank',
      'expenses',
      'loans',
      'cheques'
    ],
    'System & Operations': [
      'dashboard',
      'reports',
      'settings',
      'activity',
      'backup',
      'utilities'
    ],
  };

  static const Map<String, List<String>> systemDefaultRolePermissions = {
    'admin': allModules,
    'manager': [
      'dashboard',
      'sales',
      'purchases',
      'inventory',
      'products',
      'categories',
      'subcategories',
      'customers',
      'suppliers',
      'expenses',
      'reports',
      'settings',
      'pos',
      'activity',
      'shifts',
      'transporters',
      'utilities',
      'checkout',
    ],
    'accountant': [
      'dashboard',
      'accounting',
      'bank',
      'cash',
      'cash-bank',
      'expenses',
      'loans',
      'cheques',
      'reports',
    ],
    'stock_manager': [
      'dashboard',
      'inventory',
      'products',
      'categories',
      'subcategories',
      'purchases',
      'suppliers',
      'transporters',
      'utilities',
    ],
    'cashier': [
      'dashboard',
      'pos',
      'sales',
      'shifts',
      'checkout',
      'customers',
    ],
  };

  static String formatModuleName(String mod) {
    if (mod == 'pos') return 'POS Terminal';
    return mod
        .split('-')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // State
  final RxList<User> users = <User>[].obs;
  final RxList<Role> roles = <Role>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString updatingId = ''.obs;

  // Tabs & Filters
  final RxInt selectedTab = 0.obs; // 0: Users, 1: Roles
  final RxString searchQuery = ''.obs;
  final RxString selectedRoleFilter = 'all'.obs;

  // Current logged in user
  final Rxn<User> currentUser = Rxn<User>();

  // User Dialog Form State
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedUserRole = 'cashier'.obs;
  final RxBool isUserActive = true.obs;
  final RxList<String> userPermissions = <String>[].obs;
  final RxBool showPassword = false.obs;
  final Rxn<User> editingUser = Rxn<User>();
  final RxInt userDialogTab = 0.obs; // 0: Profile, 1: Permissions

  // Role Permissions Dialog State
  final Rxn<Role> editingRole = Rxn<Role>();
  final RxList<String> rolePermissions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _storageService.getUser();
    fetchData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _authRepository.getUsers(),
        _authRepository.getRoles(),
      ]);

      users.assignAll(results[0] as List<User>);
      roles.assignAll(results[1] as List<Role>);
    } catch (e) {
      AppSnackbar.error('Failed to load users and roles: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<User> get filteredUsers {
    final query = searchQuery.value.trim().toLowerCase();
    final roleFilter = selectedRoleFilter.value.toLowerCase();

    return users.where((u) {
      final matchesRole = roleFilter == 'all' || u.role.toLowerCase() == roleFilter;
      final matchesQuery = query.isEmpty ||
          u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          (u.phone ?? '').toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();
  }

  // --- Add / Edit User ---
  void openAddUserDialog() {
    editingUser.value = null;
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    selectedUserRole.value = 'cashier';
    isUserActive.value = true;
    showPassword.value = false;
    userDialogTab.value = 0;

    // Load cashier default permissions
    final defaultRole = roles.firstWhereOrNull(
      (r) => r.name.toLowerCase() == 'cashier',
    );
    userPermissions.assignAll(defaultRole?.permissions ?? []);
  }

  void openEditUserDialog(User user) {
    editingUser.value = user;
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phone ?? '';
    passwordController.clear();
    selectedUserRole.value = user.role;
    isUserActive.value = user.isActive;
    showPassword.value = false;
    userDialogTab.value = 0;

    if (user.permissions.isNotEmpty) {
      userPermissions.assignAll(user.permissions);
    } else {
      // Fallback to role's default permissions
      final defaultRole = roles.firstWhereOrNull(
        (r) => r.name.toLowerCase() == user.role.toLowerCase(),
      );
      userPermissions.assignAll(defaultRole?.permissions ?? []);
    }
  }

  void toggleUserPermission(String module) {
    if (userPermissions.contains(module)) {
      userPermissions.remove(module);
    } else {
      userPermissions.add(module);
    }
  }

  void toggleCategoryForUser(List<String> modules) {
    final allSelected = modules.every((m) => userPermissions.contains(m));
    if (allSelected) {
      userPermissions.removeWhere((m) => modules.contains(m));
    } else {
      for (final m in modules) {
        if (!userPermissions.contains(m)) {
          userPermissions.add(m);
        }
      }
    }
  }

  void loadDefaultsForSelectedRole() {
    final roleName = selectedUserRole.value.toLowerCase();
    final defaultRole = roles.firstWhereOrNull(
      (r) => r.name.toLowerCase() == roleName,
    );

    if (defaultRole != null && defaultRole.permissions.isNotEmpty) {
      userPermissions.assignAll(defaultRole.permissions);
      AppSnackbar.success(
        'Loaded ${defaultRole.permissions.length} default permissions for $roleName',
      );
    } else {
      final fallback = systemDefaultRolePermissions[roleName] ?? [];
      userPermissions.assignAll(fallback);
      AppSnackbar.success(
        'Loaded ${fallback.length} standard default permissions for $roleName',
      );
    }
  }

  Future<bool> saveUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      AppSnackbar.error('Please enter full name');
      return false;
    }
    if (email.isEmpty || !email.contains('@')) {
      AppSnackbar.error('Please enter a valid email address');
      return false;
    }

    final isEditing = editingUser.value != null;
    if (!isEditing && password.isEmpty) {
      AppSnackbar.error('Password is required for a new user');
      return false;
    }

    try {
      isSaving.value = true;
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        'role': selectedUserRole.value,
        'isActive': isUserActive.value,
        'permissions': userPermissions.toList(),
      };
      if (password.isNotEmpty) {
        payload['password'] = password;
      }

      if (isEditing) {
        final updated = await _authRepository.updateUser(editingUser.value!.id, payload);
        final index = users.indexWhere((u) => u.id == updated.id);
        if (index != -1) {
          users[index] = updated;
        }
        AppSnackbar.success('User updated successfully');
      } else {
        final created = await _authRepository.createUser(payload);
        users.add(created);
        AppSnackbar.success('User created successfully');
      }
      return true;
    } catch (e) {
      AppSnackbar.error('Failed to save user: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // --- Delete User ---
  Future<void> deleteUser(User user) async {
    if (user.id == currentUser.value?.id) {
      AppSnackbar.error('You cannot delete your own account');
      return;
    }

    try {
      updatingId.value = 'del-${user.id}';
      await _authRepository.deleteUser(user.id);
      users.removeWhere((u) => u.id == user.id);
      AppSnackbar.success('User ${user.name} deleted successfully');
    } catch (e) {
      AppSnackbar.error('Failed to delete user: $e');
    } finally {
      updatingId.value = '';
    }
  }

  // --- Role Default Permissions Dialog ---
  void openRoleDialog(Role role) {
    editingRole.value = role;
    rolePermissions.assignAll(role.permissions);
  }

  void toggleRolePermission(String module) {
    if (rolePermissions.contains(module)) {
      rolePermissions.remove(module);
    } else {
      rolePermissions.add(module);
    }
  }

  void toggleCategoryForRole(List<String> modules) {
    final allSelected = modules.every((m) => rolePermissions.contains(m));
    if (allSelected) {
      rolePermissions.removeWhere((m) => modules.contains(m));
    } else {
      for (final m in modules) {
        if (!rolePermissions.contains(m)) {
          rolePermissions.add(m);
        }
      }
    }
  }

  void resetRoleToSystemDefaults() {
    final role = editingRole.value;
    if (role == null) return;
    final roleName = role.name.toLowerCase();
    final fallback = systemDefaultRolePermissions[roleName] ?? [];
    rolePermissions.assignAll(fallback);
    AppSnackbar.info('Reset ${role.name} to system standard defaults (${fallback.length} modules)');
  }

  Future<bool> saveRolePermissions() async {
    final role = editingRole.value;
    if (role == null) return false;

    try {
      updatingId.value = 'role-${role.id}';
      final updated = await _authRepository.updateRolePermissions(
        role.id,
        rolePermissions.toList(),
      );
      final index = roles.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        roles[index] = updated;
      }
      AppSnackbar.success('${role.name} default permissions updated');
      return true;
    } catch (e) {
      AppSnackbar.error('Failed to update role permissions: $e');
      return false;
    } finally {
      updatingId.value = '';
    }
  }
}
