import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://rafeek-live.runasp.net'));
  
  try {
    print('1. Attempting login...');
    final loginRes = await dio.post('/v1/api/auth/login', data: {
      "email": "admin@rafeek.edu",
      "password": "Password123!"
    });
    
    final token = loginRes.data['data']['token'];
    print('Login successful! Token acquired.');
    
    // Test Study Plan
    try {
      print('\n--- GET /v1/api/study-plans/student/test-student-id ---');
      final spRes = await dio.get('/v1/api/study-plans/student/test-student-id', 
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      print('Status Code: ${spRes.statusCode}');
      print('Headers: ${spRes.headers}');
      print('Data: ${spRes.data}');
    } on DioException catch (e) {
      print('Study Plan Error: ${e.response?.statusCode}');
      print('Study Plan Response Data: ${e.response?.data}');
    }

    // Test Career Suggestions
    try {
      print('\n--- GET /v1/api/career-suggestions/student/test-student-id ---');
      final csRes = await dio.get('/v1/api/career-suggestions/student/test-student-id', 
        options: Options(headers: {'Authorization': 'Bearer $token'}));
      print('Status Code: ${csRes.statusCode}');
      print('Headers: ${csRes.headers}');
      print('Data: ${csRes.data}');
    } on DioException catch (e) {
      print('Career Suggestions Error: ${e.response?.statusCode}');
      print('Career Suggestions Response Data: ${e.response?.data}');
    }

  } on DioException catch (e) {
    print('Login failed: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
  }
}
