import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiLoggerInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;

    final StringBuffer sb = StringBuffer();
    sb.writeln('➡️ [REQUEST] ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      sb.writeln('Query Parameters: ${options.queryParameters}');
    }
    if (options.headers.isNotEmpty) {
      sb.writeln('Headers: ${options.headers}');
    }
    if (options.data != null) {
      sb.writeln('Request Body: ${options.data}');
    }

    _logger.i(sb.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final int startTime =
        response.requestOptions.extra['request_start_time'] as int? ??
        DateTime.now().millisecondsSinceEpoch;
    final int duration = DateTime.now().millisecondsSinceEpoch - startTime;

    final StringBuffer sb = StringBuffer();
    sb.writeln(
      '⬅️ [RESPONSE ${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    sb.writeln('Duration: ${duration}ms');
    sb.writeln('Response Body: ${response.data}');

    _logger.d(sb.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final int startTime =
        err.requestOptions.extra['request_start_time'] as int? ??
        DateTime.now().millisecondsSinceEpoch;
    final int duration = DateTime.now().millisecondsSinceEpoch - startTime;

    final StringBuffer sb = StringBuffer();
    sb.writeln(
      '❌ [ERROR ${err.response?.statusCode ?? 'NETWORK_ERROR'}] ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    sb.writeln('Duration: ${duration}ms');
    if (err.requestOptions.queryParameters.isNotEmpty) {
      sb.writeln('Query Parameters: ${err.requestOptions.queryParameters}');
    }
    if (err.requestOptions.data != null) {
      sb.writeln('Request Body: ${err.requestOptions.data}');
    }
    if (err.response?.data != null) {
      sb.writeln('Response Body: ${err.response?.data}');
    }
    sb.writeln('Error Message: ${err.message}');
    sb.writeln('Stack Trace:\n${err.stackTrace}');

    _logger.e(sb.toString());
    handler.next(err);
  }
}
