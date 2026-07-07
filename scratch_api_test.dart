
import 'dart:developer';
import 'package:dio/dio.dart';

void main() async {
  final requestBody = {
    'email': 'student@rafeek.edu.eg',
    'confirmationCode': '123456',
  };

  log('=== TEST 1: Request WITHOUT Authorization Header ===');
  final dioWithoutToken = Dio(
    BaseOptions(
      baseUrl: 'https://rafeek-live.runasp.net',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  try {
    log('Sending POST /v1/api/activate-university-email...');
    final response = await dioWithoutToken.post(
      '/v1/api/activate-university-email',
      data: requestBody,
    );
    log('Response Status Code: ${response.statusCode}');
    log('Response Headers: ${response.headers}');
    log('Response Body: ${response.data}');
  } on DioException catch (e) {
    log('Dio Error Status Code: ${e.response?.statusCode}');
    log('Dio Error Headers: ${e.response?.headers}');
    log('Dio Error Body: ${e.response?.data}');
  } catch (e) {
    log('Generic Error: $e');
  }

  log('\n=== TEST 2: Request WITH Authorization Header (Admin Token) ===');
  final adminToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkJlYXJlciJ9.eyJ1bmlxdWVfbmFtZSI6IkNvcmRpZV9TYXdheW42NDgiLCJuYW1laWQiOiI1YzdmNmEzOS03MzMxLTQyMmUtYmE4YS01NDE3ZWVkYzAxNzkiLCJlbWFpbCI6IkNvcmRpZV9TYXdheW42NDhAcmFmZWVrLmVkdSIsIm5iZiI6MTc3NzMxOTA1NCwiZXhwIjoxODA4ODU1MDU0LCJqdGkiOiJkODhkNGJiOC1lN2E4LTQ3NmUtYWYxMS01N2E2OWUzN2I1NzIiLCJVc2VyVHlwZXMiOiIxIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJpYXQiOjE3NzczMTkwNTQsImlzcyI6Imh0dHBzOi8vcmFmZWVrLWxpdmUucnVuYXNwLm5ldC8ifQ.2buC9yRUym8kUJv6BZ5oViDQALZo1rpNcFxHUFWwoQg';
  final dioWithToken = Dio(
    BaseOptions(
      baseUrl: 'https://rafeek-live.runasp.net',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $adminToken',
      },
    ),
  );

  try {
    log('Sending POST /v1/api/activate-university-email...');
    final response = await dioWithToken.post(
      '/v1/api/activate-university-email',
      data: requestBody,
    );
    log('Response Status Code: ${response.statusCode}');
    log('Response Headers: ${response.headers}');
    log('Response Body: ${response.data}');
  } on DioException catch (e) {
    log('Dio Error Status Code: ${e.response?.statusCode}');
    log('Dio Error Headers: ${e.response?.headers}');
    log('Dio Error Body: ${e.response?.data}');
  } catch (e) {
    log('Generic Error: $e');
  }
}
