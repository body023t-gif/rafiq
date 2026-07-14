import 'package:rafiq/core/network/api_service.dart';

class TimetableRemoteDataSource {
  final ApiService apiService;

  const TimetableRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> generateTimetable(Map<String, dynamic> body) {
    return apiService.post('/v1/api/ai/timetable', body: body);
  }

  Future<Map<String, dynamic>> saveTimetable(Map<String, dynamic> body) {
    return apiService.post('/v1/api/ai/timetable/save', body: body);
  }

  Future<Map<String, dynamic>> getCourseDetails(String courseId) {
    return apiService.get('/v1/api/courses/$courseId');
  }

  Future<Map<String, dynamic>> getStudentSchedule() {
    return apiService.get('/v1/api/students/schedule');
  }

  Future<List<dynamic>> getSavedTimetables(String studentId) {
    return apiService.getList('/v1/api/ai/timetable/student/$studentId');
  }
}
