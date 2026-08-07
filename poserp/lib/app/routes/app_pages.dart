import 'package:get/get.dart';
import '../../modules/authentication/bindings/auth_binding.dart';
import '../../modules/authentication/views/forgot_password_view.dart';
import '../../modules/authentication/views/login_view.dart';
import '../../modules/authentication/views/register_view.dart';
import '../../modules/cash_bank/bindings/cash_bank_binding.dart';
import '../../modules/cash_bank/views/cash_bank_list_view.dart';
import '../../modules/dashboard_placeholder/dashboard_placeholder_view.dart';
import '../../modules/expenses/bindings/expense_binding.dart';
import '../../modules/expenses/views/expense_list_view.dart';
import '../../modules/parties/customers/bindings/customer_binding.dart';
import '../../modules/parties/customers/views/customer_list_view.dart';
import '../../modules/parties/suppliers/bindings/supplier_binding.dart';
import '../../modules/parties/suppliers/views/supplier_list_view.dart';
import '../../modules/parties/transporters/bindings/transporter_binding.dart';
import '../../modules/parties/transporters/views/transporter_list_view.dart';
import '../../modules/pos/bindings/pos_binding.dart';
import '../../modules/pos/views/pos_view.dart';
import '../../modules/products/bindings/product_binding.dart';
import '../../modules/products/categories/bindings/category_binding.dart';
import '../../modules/products/categories/views/category_list_view.dart';
import '../../modules/products/inventory/bindings/stock_binding.dart';
import '../../modules/products/inventory/views/inventory_view.dart';
import '../../modules/products/opening_stock/bindings/opening_stock_binding.dart';
import '../../modules/products/opening_stock/views/opening_stock_view.dart';
import '../../modules/products/subcategories/bindings/subcategory_binding.dart';
import '../../modules/products/subcategories/views/subcategory_list_view.dart';
import '../../modules/products/views/product_list_view.dart';
import '../../modules/purchases/bindings/purchase_binding.dart';
import '../../modules/purchases/payment_out/bindings/payment_out_binding.dart';
import '../../modules/purchases/payment_out/views/payment_out_list_view.dart';
import '../../modules/purchases/return/bindings/purchase_return_binding.dart';
import '../../modules/purchases/return/views/purchase_return_list_view.dart';
import '../../modules/purchases/views/purchase_detail_view.dart';
import '../../modules/purchases/views/purchase_form_view.dart';
import '../../modules/purchases/views/purchase_list_view.dart';
import '../../modules/sales/bindings/sale_binding.dart';
import '../../modules/sales/payment_in/bindings/payment_in_binding.dart';
import '../../modules/sales/payment_in/views/payment_in_list_view.dart';
import '../../modules/sales/return/bindings/sale_return_binding.dart';
import '../../modules/sales/return/views/sale_return_form_view.dart';
import '../../modules/sales/return/views/sale_return_list_view.dart';
import '../../modules/sales/views/sale_list_view.dart';
import '../../modules/shifts/bindings/shift_binding.dart';
import '../../modules/shifts/views/shift_management_view.dart';
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
    GetPage(
      name: Routes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.openingStock,
      page: () => const OpeningStockView(),
      binding: OpeningStockBinding(),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryView(),
      binding: StockBinding(),
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomerListView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: Routes.suppliers,
      page: () => const SupplierListView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: Routes.transporters,
      page: () => const TransporterListView(),
      binding: TransporterBinding(),
    ),
    GetPage(
      name: Routes.pos,
      page: () => const POSView(),
      binding: POSBinding(),
    ),
    GetPage(
      name: Routes.sales,
      page: () => const SaleListView(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: Routes.paymentIn,
      page: () => const PaymentInListView(),
      binding: PaymentInBinding(),
    ),
    GetPage(
      name: Routes.saleReturn,
      page: () => const SaleReturnListView(),
      binding: SaleReturnBinding(),
    ),
    GetPage(
      name: Routes.saleReturnCreate,
      page: () => const SaleReturnFormView(),
      binding: SaleReturnBinding(),
    ),
    GetPage(
      name: Routes.purchases,
      page: () => const PurchaseListView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseCreate,
      page: () => const PurchaseFormView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseDetail,
      page: () => const PurchaseDetailView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseReturn,
      page: () => const PurchaseReturnListView(),
      binding: PurchaseReturnBinding(),
    ),
    GetPage(
      name: Routes.paymentOut,
      page: () => const PaymentOutListView(),
      binding: PaymentOutBinding(),
    ),
    GetPage(
      name: Routes.expenses,
      page: () => const ExpenseListView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.cashBank,
      page: () => const CashBankListView(),
      binding: CashBankBinding(),
    ),
    GetPage(
      name: Routes.shifts,
      page: () => const ShiftManagementView(),
      binding: ShiftBinding(),
    ),
  ];
}
