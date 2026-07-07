import 'dart:developer';
import 'package:rafiq/core/network/api_service.dart';

class StudyPlanRemoteDataSource {
  final ApiService apiService;

  const StudyPlanRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getStudyPlan(String studentId) async {
    // TODO(Backend): Replace this temporary mapping with the dedicated Study Plan Improvement endpoint when it becomes available.
    final path = '/v1/api/ai/recommendations?studentId=$studentId';
    log('[StudyPlanRemoteDataSource] GET $path');
    
    try {
      final response = await apiService.get(path);
      log('[StudyPlanRemoteDataSource] Response: $response');
      return response;
    } catch (e) {
      log('[StudyPlanRemoteDataSource] Error: $e');
      rethrow;
    }
  }
}
