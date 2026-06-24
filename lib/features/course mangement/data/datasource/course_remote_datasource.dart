import 'package:rafiq/core/network/api_service.dart';

class CourseRemoteDataSource {
  final ApiService apiService;

  const CourseRemoteDataSource(this.apiService);

  Future<List<Map<String, dynamic>>> getCourses({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) {
    return apiService.getList(
      '/v1/api/courses',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> getCourseById(String courseId) {
    return apiService.get('/v1/api/courses/$courseId');
  }

  Future<Map<String, dynamic>> addCourse(Map<String, dynamic> body) {
    return apiService.post('/v1/api/courses/add', body: body);
  }

  Future<Map<String, dynamic>> updateCourse(
    String courseId,
    Map<String, dynamic> body,
  ) {
    return apiService.put('/v1/api/courses/$courseId/update', body: body);
  }

  Future<Map<String, dynamic>> deleteCourse(String courseId) {
    return apiService.delete('/v1/api/courses/$courseId/delete');
  }
}
