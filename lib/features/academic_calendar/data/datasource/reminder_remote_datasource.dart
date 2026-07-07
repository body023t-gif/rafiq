import 'package:rafiq/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:rafiq/data/api/api_exception.dart';
import 'dart:developer' as dev;

class ReminderRemoteDataSource {
  final ApiService apiService;

  const ReminderRemoteDataSource(this.apiService);

  Future<List<Map<String, dynamic>>> getReminders() async {
    final data = await apiService.getList('/v1/api/reminders/getall/pagginated');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> addReminder(Map<String, dynamic> body) async {
    return await apiService.post('/v1/api/reminders/add', body: body);
  }

  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> body) async {
    const isDebug = !bool.fromEnvironment('dart.vm.product');
    
    if (isDebug) {
      dev.log('========== [Reminder PUT Request Log] ==========');
      dev.log('Endpoint URL: /v1/api/reminders/$id/update');
      dev.log('Route id: $id');
      dev.log('Complete JSON body: $body');
      dev.log('Reminder model id (in body): ${body['id']}');
      dev.log('================================================');
    }

    try {
      final response = await apiService.dio.put<Map<String, dynamic>>(
        '/v1/api/reminders/$id/update',
        data: body,
      );
      
      final data = response.data;
      final headers = response.headers.map;
      
      if (isDebug) {
        dev.log('========== [Reminder PUT Response Log] ==========');
        dev.log('Parsed backend response: $data');
        dev.log('Response headers: $headers');
        dev.log('==================================================');
      }
      
      if (data == null) {
        throw const ApiException('Empty response received from server.');
      }
      
      final success = data['success'];
      if (success is bool && !success) {
        throw ApiException(
          (data['message'] ?? 'Request failed. Please try again.').toString(),
          statusCode: (data['statusCode'] as num?)?.toInt() ?? response.statusCode,
        );
      }
      
      final innerData = data['data'];
      if (innerData is Map<String, dynamic>) {
        return innerData;
      }
      if (innerData is! Map<String, dynamic> && innerData != null) {
        return {'data': innerData};
      }
      if (innerData == null && success == true) {
        return const {};
      }
      throw const ApiException('Malformed response: "data" object is missing.');
    } on DioException catch (e) {
      if (isDebug) {
        dev.log('========== [Reminder PUT Error Log] ==========');
        dev.log('Exception Type: ${e.type}');
        dev.log('Error Message: ${e.message}');
        dev.log('Status Code: ${e.response?.statusCode}');
        dev.log('Response Headers: ${e.response?.headers.map}');
        dev.log('Response Body: ${e.response?.data}');
        dev.log('===============================================');
      }
      String errMsg = 'حدث خطأ غير متوقع أثناء الاتصال بالخادم.';
      if (e.response?.data is Map<String, dynamic>) {
        final respData = e.response!.data as Map<String, dynamic>;
        errMsg = (respData['message'] ?? respData['detail'] ?? respData['title'] ?? errMsg).toString();
      }
      throw ApiException(errMsg, statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteReminder(String id) async {
    await apiService.delete('/v1/api/reminders/$id/delete');
  }
}
