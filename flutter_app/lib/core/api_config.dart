class ApiConfig {
  const ApiConfig({required this.baseUrl});

  /// Android emulator: http://10.0.2.2:8000
  /// iOS simulator / desktop: http://127.0.0.1:8000
  final String baseUrl;

  static const current = ApiConfig(baseUrl: 'http://127.0.0.1:8000');
}
