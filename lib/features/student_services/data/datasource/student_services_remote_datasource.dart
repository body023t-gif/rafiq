import 'dart:developer';

import 'package:rafiq/core/network/api_service.dart';
import 'package:rafiq/core/utils/text_encoding.dart';
import 'package:rafiq/features/student_services/models/document_request_command.dart';

class StudentServicesRemoteDataSource {
  final ApiService apiService;

  const StudentServicesRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getInitialData() async {
    log('[Booking] Calling RemoteDataSource.getInitialData...');
    final path = '/v1/api/students/academic-service/initial-data';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    final maskedToken = token.length > 20
        ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
        : token;

    log('[Network Trace] GET $path');
    log('  - Method: GET');
    log('  - Headers: { "Content-Type": "application/json", "Authorization": "Bearer $maskedToken" }');
    log('  - ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}');
    log('  - ApiService.dynamicUserId: ${ApiService.dynamicUserId}');

    final startTime = DateTime.now();
    try {
      final response = await apiService.get(path);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      log('[Network Response] GET $path');
      log('  - Status Code: 200');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Raw Response Body: $response');
      log('  - Decoded Response: $response');
      
      log('[Initial Data] Loaded academic service metadata:');
      log('  - Student Name: ${repairUtf8Text((response['studentName'] ?? response['StudentName'] ?? '').toString())}');
      log('  - University Code: ${response['universityCode'] ?? response['UniversityCode']}');
      log('  - Department: ${repairUtf8Text((response['departmentName'] ?? response['DepartmentName'] ?? '').toString())}');
      log('  - Advisor: ${repairUtf8Text((response['advisorName'] ?? response['AdvisorName'] ?? '').toString())}');

      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('[Network Error] GET $path');
      log('  - Request Duration: ${duration.inMilliseconds} ms');
      log('  - Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> body) async {
    log('[Booking] Calling RemoteDataSource.bookService...');
    final path = '/v1/api/students/academic-service/book';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    final maskedToken = token.length > 20
        ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
        : token;

    log('[Network Trace] POST $path');
    log('  - Method: POST');
    log('  - Headers: { "Content-Type": "application/json", "Authorization": "Bearer $maskedToken" }');
    log('  - ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}');
    log('  - ApiService.dynamicUserId: ${ApiService.dynamicUserId}');
    log('  - Complete Payload (Body) JSON: $body');

    final startTime = DateTime.now();
    try {
      final response = await apiService.post(path, body: body);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      log('[Network Response] POST $path');
      log('  - Status Code: 200');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Raw Response Body: $response');
      log('  - Decoded Response: $response');
      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('[Network Error] POST $path');
      log('  - Request Duration: ${duration.inMilliseconds} ms');
      log('  - Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendGuidanceRequest(Map<String, dynamic> body) async {
    log('[Booking] Calling RemoteDataSource.sendGuidanceRequest...');
    final path = '/v1/api/students/guidance-request/send';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    final maskedToken = token.length > 20
        ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
        : token;

    log('[Network Trace] POST $path');
    log('  - Method: POST');
    log('  - Headers: { "Content-Type": "application/json", "Authorization": "Bearer $maskedToken" }');
    log('  - ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}');
    log('  - ApiService.dynamicUserId: ${ApiService.dynamicUserId}');
    log('  - Complete Payload (Body) JSON: $body');

    // Warning validation: Verify StudentId is NOT accidentally UserId
    final studentId = body['studentId']?.toString();
    if (studentId == ApiService.dynamicUserId || studentId == ApiService.staticUserId) {
      log('⚠️ WARNING: studentId in guidance request payload is equal to UserId ($studentId) instead of StudentId!');
    } else {
      log('ℹ️ INFO: studentId in guidance request payload is: $studentId');
    }

    final startTime = DateTime.now();
    try {
      final response = await apiService.post(path, body: body);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      log('[Network Response] POST $path');
      log('  - Status Code: 200');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Raw Response Body: $response');
      log('  - Decoded Response: $response');
      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('[Network Error] POST $path');
      log('  - Request Duration: ${duration.inMilliseconds} ms');
      log('  - Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestDocument(DocumentRequestCommand command) async {
    log('[Booking] Calling RemoteDataSource.requestDocument...');
    final path = '/v1/api/document-requests';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    final maskedToken = token.length > 20
        ? '${token.substring(0, 10)}...${token.substring(token.length - 10)}'
        : token;

    final body = command.toJson();

    log('[Network Trace] POST $path');
    log('  - Method: POST');
    log('  - Headers: { "Content-Type": "application/json", "Authorization": "Bearer $maskedToken" }');
    log('  - Complete Payload (Body) JSON: $body');

    final startTime = DateTime.now();
    try {
      final response = await apiService.post(path, body: body);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      log('[Network Response] POST $path');
      log('  - Status Code: 200');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Raw Response Body: $response');
      log('  - Decoded Response: $response');
      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('[Network Error] POST $path');
      log('  - Request Duration: ${duration.inMilliseconds} ms');
      log('  - Exception: $e');
      rethrow;
    }
  }
}
