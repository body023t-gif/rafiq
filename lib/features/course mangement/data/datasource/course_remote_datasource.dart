import 'package:rafiq/core/network/api_service.dart';

class CourseRemoteDataSource {
  final ApiService apiService;

  const CourseRemoteDataSource(this.apiService);

  Future<List<Map<String, dynamic>>> getCourses({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    final response = await apiService.getList(
      '/v1/api/courses',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    // TEMPORARY DEBUG LOGGING FOR COURSE REGISTRATION AUDIT
    print('\n====== GET COURSES RAW JSON START ======');
    for (var course in response) {
      print('Course JSON: $course');
      final sections = course['sections'] ?? course['courseSections'] ?? [];
      if (sections is List) {
        for (var section in sections) {
          print('  Section JSON: $section');
        }
      }
    }
    print('====== GET COURSES RAW JSON END ======\n');

    return response;
  }

  Future<Map<String, dynamic>> getCourseById(String courseId) {
    return apiService.get('/v1/api/courses/$courseId');
  }

  Future<Map<String, dynamic>> enrollCourse(String courseId, String sectionId) {
    return apiService.post(
      '/v1/api/courses/enroll',
      body: {
        'courseId': courseId,
        'lectureGroupId': sectionId, // Map sectionId to backend-expected lectureGroupId
      },
    );
  }

  Future<Map<String, dynamic>> dropCourse(String courseId) {
    return apiService.post(
      '/v1/api/courses/drop',
      body: {
        'courseId': courseId,
      },
    );
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
