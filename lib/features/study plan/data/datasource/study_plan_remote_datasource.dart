import 'package:rafiq/core/network/api_service.dart';

class StudyPlanRemoteDataSource {
  final ApiService apiService;

  const StudyPlanRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getStudyPlan(String studentId) {
    return apiService.get('/v1/api/study-plans/student/$studentId');
  }
}
