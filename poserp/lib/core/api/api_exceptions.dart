import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  AppException({required this.message, this.statusCode, this.data});

  factory AppException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          message:
              'Connection timed out. Please check your network connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'An unexpected server error occurred.';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message') &&
              responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }

        if (statusCode == 401 &&
            message == 'An unexpected server error occurred.') {
          message = 'Unauthorized. Invalid email or password.';
        }

        return AppException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case DioExceptionType.cancel:
        return AppException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return AppException(
          message:
              'Unable to connect to the server. Please verify network connectivity.',
        );
      default:
        return AppException(
          message: error.message ?? 'An unknown error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
