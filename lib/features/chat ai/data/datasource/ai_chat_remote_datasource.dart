import 'dart:developer';

import 'package:rafiq/core/network/api_service.dart';
import 'package:rafiq/core/error/api_exception.dart';

class AiChatRemoteDataSource {
  final ApiService apiService;

  const AiChatRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> askQuestion(Map<String, dynamic> body) async {
    final path = '/v1/api/ai/ask';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    
    // Print current timeout values of the Dio instance
    final connectTimeoutSec = apiService.dio.options.connectTimeout?.inSeconds ?? -1;
    final receiveTimeoutSec = apiService.dio.options.receiveTimeout?.inSeconds ?? -1;
    final sendTimeoutSec = apiService.dio.options.sendTimeout?.inSeconds ?? -1;

    log('========== [Dio Timeout Check] ==========');
    log('  - connectTimeout: $connectTimeoutSec seconds');
    log('  - receiveTimeout: $receiveTimeoutSec seconds');
    log('  - sendTimeout: $sendTimeoutSec seconds');
    log('========================================');

    final startTime = DateTime.now();
    log('========== [API Request: POST $path] ==========');
    log('  - Request Start Time: $startTime');
    log('  - Full URL: https://rafeek-live.runasp.net$path');
    log('  - Headers: {"Content-Type": "application/json", "Authorization": "Bearer ***"}');
    log('  - Authorization Token: $token');
    log('  - SessionId: ${body['sessionId']}');
    log('  - Request Body: $body');
    log('=============================================');
    
    try {
      final response = await apiService.post(path, body: body);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('========== [API Response: POST $path] ==========');
      log('  - Response Arrival Time: $endTime');
      log('  - Total Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Status Code: 200');
      log('  - Response Body: $response');
      log('==============================================');
      return response;
    } on ApiException catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('========== [API ApiException Error: POST $path] ==========');
      log('  - Error Time: $endTime');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Exception Message: ${e.message}');
      log('  - Status Code: ${e.statusCode}');
      log('========================================================');
      rethrow;
    } catch (e, stackTrace) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('========== [API Error: POST $path] ==========');
      log('  - Error Time: $endTime');
      log('  - Request Duration: ${duration.inMilliseconds} ms (${duration.inSeconds} seconds)');
      log('  - Exception: $e');
      log('  - Exception Type: ${e.runtimeType}');
      log('  - Stack Trace: $stackTrace');
      log('============================================');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final path = '/v1/api/ai/sessions';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    
    log('========== [API Request: GET $path] ==========');
    log('  - Full URL: https://rafeek-live.runasp.net$path');
    log('  - Headers: {"Content-Type": "application/json", "Authorization": "Bearer ***"}');
    log('  - Authorization Token: $token');
    
    try {
      final response = await apiService.getList(path);
      log('========== [API Response: GET $path] ==========');
      log('  - Status Code: 200');
      log('  - Raw Response: $response');
      log('  - Decoded Response: $response');
      return response;
    } catch (e) {
      log('========== [API Error: GET $path] ==========');
      log('  - Exception: $e');
      log('  - Exception Type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getHistory({String? sessionId}) async {
    final path = '/v1/api/ai/history';
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    
    log('========== [API Request: GET $path] ==========');
    log('  - Full URL: https://rafeek-live.runasp.net$path');
    log('  - Headers: {"Content-Type": "application/json", "Authorization": "Bearer ***"}');
    log('  - Authorization Token: $token');
    log('  - SessionId: $sessionId');
    
    final queryParameters = {
      if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
    };
    
    try {
      final response = await apiService.getList(path, queryParameters: queryParameters);
      log('========== [API Response: GET $path] ==========');
      log('  - Status Code: 200');
      log('  - Raw Response: $response');
      log('  - Decoded Response: $response');
      return response;
    } catch (e) {
      log('========== [API Error: GET $path] ==========');
      log('  - Exception: $e');
      log('  - Exception Type: ${e.runtimeType}');
      rethrow;
    }
  }
}
