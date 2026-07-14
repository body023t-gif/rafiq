import 'dart:developer';

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
    log('\n====== GET COURSES RAW JSON START ======');
    for (var course in response) {
      log('Course JSON: $course');
      final sections = course['sections'] ?? course['courseSections'] ?? [];
      if (sections is List) {
        for (var section in sections) {
          log('  Section JSON: $section');
        }
      }
    }
    log('====== GET COURSES RAW JSON END ======\n');

    return response;
  }

  Future<Map<String, dynamic>> getCourseById(String courseId) {
    return apiService.get('/v1/api/courses/$courseId');
  }

  Future<Map<String, dynamic>> enrollCourse(
    String courseId,
    String lectureGroupId,
    String sectionId,
  ) {
    final body = {
      'courseId': courseId,
      'lectureGroupId': lectureGroupId,
      'sectionId': sectionId,
    };
    log('====== ENROLL COURSE DEBUG ======');
    log('selected lectureGroupId: $lectureGroupId, sectionId: $sectionId');
    log('request body before POST: $body');
    log('=================================');
    return apiService.post(
      '/v1/api/courses/enroll',
      body: body,
    );
  }

  Future<Map<String, dynamic>> dropCourse(String courseId) {
    return apiService.post(
      '/v1/api/courses/drop',
      body: {'courseId': courseId},
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
