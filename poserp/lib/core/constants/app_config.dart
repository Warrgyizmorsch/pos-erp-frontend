class AppConfig {
  static const String appName = 'POS ERP';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pos-erp-backend.onrender.com/api',
  );

  static const Duration connectTimeout = Duration(seconds: 35);
  static const Duration receiveTimeout = Duration(seconds: 35);
}
