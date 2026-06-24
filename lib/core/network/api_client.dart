import 'package:rafiq/core/network/api_service.dart';

ApiService createApiService() {
  return ApiService(
    baseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://rafeek-live.runasp.net',
    ),
    acceptLanguage: const String.fromEnvironment(
      'ACCEPT_LANGUAGE',
      defaultValue: '',
    ).isEmpty
        ? null
        : const String.fromEnvironment('ACCEPT_LANGUAGE'),
  );
}
