import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/import_export_controller.dart';

class ImportExportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImportExportController>(
      () => ImportExportController(Get.find<ApiClient>()),
    );
  }
}
