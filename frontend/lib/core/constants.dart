class Constants {
  static const String apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.1.102',
  );

  static const String apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '5076',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.102:5076/api',
  );

  /// Returns the API base URL, using dart-define overrides if provided.
  /// Use this when you need a runtime-computed URL based on API_HOST/API_PORT.
  static String get resolvedBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return 'http://$apiHost:$apiPort/api';
  }
}
