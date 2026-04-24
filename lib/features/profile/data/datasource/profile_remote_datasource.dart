import 'package:rafiq/core/network/api_service.dart';

class ProfileRemoteDataSource {
  final ApiService apiService;

  const ProfileRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getProfile() {
    return apiService.get('/v1/api/students/profile');
  }
}
