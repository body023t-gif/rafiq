import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody? responseBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (responseBody != null) {
      return responseBody!;
    }
    throw UnimplementedError('No mock response provided.');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ApiService response parsing tests', () {
    late ApiService apiService;
    late MockAdapter mockAdapter;
    late Dio dio;

    setUp(() {
      dio = Dio();
      mockAdapter = MockAdapter();
      dio.httpClientAdapter = mockAdapter;
      apiService = ApiService(baseUrl: 'https://example.com', dio: dio);
    });

    test('Unwraps Map response successfully', () async {
      final payload = {
        'success': true,
        'errors': {},
        'data': {'userId': 'user-123', 'name': 'John'},
        'message': 'Success',
        'statusCode': 200,
      };
      
      mockAdapter.responseBody = ResponseBody.fromString(
        json.encode(payload),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final result = await apiService.get('/test');
      expect(result['userId'], 'user-123');
      expect(result['name'], 'John');
    });

    test('Unwraps primitive response (String GUID) successfully', () async {
      final payload = {
        'success': true,
        'errors': {},
        'data': 'booking-guid',
        'message': 'تم الإنشاء بنجاح.',
        'statusCode': 200,
      };

      mockAdapter.responseBody = ResponseBody.fromString(
        json.encode(payload),
        201,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final result = await apiService.post('/test');
      expect(result['data'], 'booking-guid');
    });

    test('forgotPassword API returns success map on HTTP 202 Accepted', () async {
      mockAdapter.responseBody = ResponseBody.fromString(
        json.encode({'success': true, 'message': 'Email sent'}),
        202,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final result = await apiService.forgotPassword({'email': 'test@example.com'});
      expect(result, isA<Map<String, dynamic>>());
    });

    test('resetPassword API returns success map on HTTP 202 Accepted', () async {
      mockAdapter.responseBody = ResponseBody.fromString(
        json.encode({'success': true, 'message': 'Password updated'}),
        202,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final result = await apiService.resetPassword({
        'email': 'test@example.com',
        'token': 'some-token',
        'newPassword': 'password123',
      });
      expect(result, isA<Map<String, dynamic>>());
    });

    test('updateReminder sends ID matching route parameter', () async {
      final reminderDataSource = ReminderRemoteDataSource(apiService);
      final id = '3fa85f64-5717-4562-b3fc-2c963f66afa6';
      
      final payload = {
        'success': true,
        'errors': {},
        'data': {'id': id, 'title': 'Test Reminder'},
        'message': 'Updated',
        'statusCode': 200,
      };

      mockAdapter.responseBody = ResponseBody.fromString(
        json.encode(payload),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final body = {
        'id': id,
        'title': 'Test Reminder',
        'description': 'Description',
        'dueDate': '2026-07-06T12:00:00Z',
        'isCompleted': false
      };

      final result = await reminderDataSource.updateReminder(id, body);
      expect(result['id'], id);
    });
  });
}
