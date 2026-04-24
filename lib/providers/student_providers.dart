import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/models/dashboard_model.dart';
import 'package:rafiq/models/profile_model.dart';
import 'package:rafiq/repository/student_repository.dart';

const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://rafeek-live.runasp.net',
);
const String kAcceptLanguage = String.fromEnvironment(
  'ACCEPT_LANGUAGE',
  defaultValue: '',
);

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    baseUrl: kApiBaseUrl,
    acceptLanguage: kAcceptLanguage.isEmpty ? null : kAcceptLanguage,
  );
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(ref.watch(apiServiceProvider));
});

final studentProfileProvider = FutureProvider<StudentProfileModel>((ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getProfile();
});

final studentDashboardProvider =
    FutureProvider.family<StudentDashboardModel, String>((ref, userId) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getDashboard(userId);
});
