import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/models/dashboard_model.dart';
import 'package:rafiq/models/profile_model.dart';

class StudentRepository {
  final ApiService _apiService;
  StudentProfileModel? _cachedProfile;
  final Map<String, StudentDashboardModel> _cachedDashboards = {};

  StudentRepository(this._apiService);

  Future<StudentProfileModel> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile!;
    }

    final data = await _fetchWithRetry(
      () => _apiService.get('/v1/api/students/profile'),
    );
    final profile = StudentProfileModel.fromJson(data);
    _cachedProfile = profile;
    return profile;
  }

  Future<StudentDashboardModel> getDashboard(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedDashboards.containsKey(userId)) {
      return _cachedDashboards[userId]!;
    }

    final data = await _fetchWithRetry(
      () => _apiService.get('/v1/api/students/dashboard/$userId'),
    );
    final dashboard = StudentDashboardModel.fromJson(data);
    _cachedDashboards[userId] = dashboard;
    return dashboard;
  }

  Future<Map<String, dynamic>> _fetchWithRetry(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } catch (_) {
      return call();
    }
  }
}
