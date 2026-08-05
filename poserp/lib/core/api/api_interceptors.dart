import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import '../../data/services/storage_service.dart';

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Get.isRegistered<StorageService>()) {
      final storage = Get.find<StorageService>();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    if (options.data is FormData) {
      options.headers.remove('Content-Type');
    } else if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        storage.clearSession();
      }
      // If token expired, redirect to login route
      Get.offAllNamed('/login');
    }
    return handler.next(err);
  }
}
