class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://frock-backend.purplestone-add9d7b8.eastus.azurecontainerapps.io/api',
  );
}
