import 'pagination.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? token;
  final Pagination? pagination;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.token,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      token: json['token'],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}
