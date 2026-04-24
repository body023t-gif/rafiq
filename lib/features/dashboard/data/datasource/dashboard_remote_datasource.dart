import 'package:rafiq/core/network/api_service.dart';

class DashboardRemoteDataSource {
  final ApiService apiService;

  const DashboardRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getDashboard(String userId) {
    return apiService.get('/v1/api/students/dashboard/$userId');
  }
}
