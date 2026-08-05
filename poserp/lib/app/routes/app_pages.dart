import 'package:get/get.dart';
import '../../modules/authentication/bindings/auth_binding.dart';
import '../../modules/authentication/views/forgot_password_view.dart';
import '../../modules/authentication/views/login_view.dart';
import '../../modules/authentication/views/register_view.dart';
import '../../modules/dashboard_placeholder/dashboard_placeholder_view.dart';
import '../../modules/products/categories/bindings/category_binding.dart';
import '../../modules/products/categories/views/category_list_view.dart';
import '../../modules/products/subcategories/bindings/subcategory_binding.dart';
import '../../modules/products/subcategories/views/subcategory_list_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardPlaceholderView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoryListView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.subcategories,
      page: () => const SubcategoryListView(),
      binding: SubcategoryBinding(),
    ),
  ];
}
