import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://rafeek-live.runasp.net',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkJlYXJlciJ9.eyJ1bmlxdWVfbmFtZSI6IkNvcmRpZV9TYXdheW42NDgiLCJuYW1laWQiOiI1YzdmNmEzOS03MzMxLTQyMmUtYmE4YS01NDE3ZWVkYzAxNzkiLCJlbWFpbCI6IkNvcmRpZV9TYXdheW42NDhAcmFmZWVrLmVkdSIsIm5iZiI6MTc3NzMxOTA1NCwiZXhwIjoxODA4ODU1MDU0LCJqdGkiOiJkODhkNGJiOC1lN2E4LTQ3NmUtYWYxMS01N2E2OWUzN2I1NzIiLCJVc2VyVHlwZXMiOiIxIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJpYXQiOjE3NzczMTkwNTQsImlzcyI6Imh0dHBzOi8vcmFmZWVrLWxpdmUucnVuYXNwLm5ldC8ifQ.2buC9yRUym8kUJv6BZ5oViDQALZo1rpNcFxHUFWwoQg',
      },
    ),
  );

  try {
    print('Calling /v1/api/students/profile...');
    final response = await dio.get('/v1/api/students/profile');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');
  } on DioException catch (e) {
    print('Dio Error: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
  } catch (e) {
    print('Generic Error: $e');
  }
}
