class Constants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://faims.duckdns.org/api',
  );
}
