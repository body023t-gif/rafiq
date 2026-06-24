import 'package:rafiq/core/network/api_service.dart';

class ScheduleRemoteDataSource {
  final ApiService apiService;

  const ScheduleRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getSchedule() {
    return apiService.get('/v1/api/students/schedule');
  }
}
