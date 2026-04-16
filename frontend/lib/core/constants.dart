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

  static String get resolvedBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return 'http://$apiHost:$apiPort/api';
  }
}
