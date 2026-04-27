import 'package:dio/dio.dart';
import 'package:rafiq/data/api/api_exception.dart';

class ApiService {
  static const String staticToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkJlYXJlciJ9.eyJ1bmlxdWVfbmFtZSI6IkNvcmRpZV9TYXdheW42NDgiLCJuYW1laWQiOiI1YzdmNmEzOS03MzMxLTQyMmUtYmE4YS01NDE3ZWVkYzAxNzkiLCJlbWFpbCI6IkNvcmRpZV9TYXdheW42NDhAcmFmZWVrLmVkdSIsIm5iZiI6MTc3NzMxOTA1NCwiZXhwIjoxODA4ODU1MDU0LCJqdGkiOiJkODhkNGJiOC1lN2E4LTQ3NmUtYWYxMS01N2E2OWUzN2I1NzIiLCJVc2VyVHlwZXMiOiIxIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJpYXQiOjE3NzczMTkwNTQsImlzcyI6Imh0dHBzOi8vcmFmZWVrLWxpdmUucnVuYXNwLm5ldC8ifQ.2buC9yRUym8kUJv6BZ5oViDQALZo1rpNcFxHUFWwoQg';
  static const String staticUserId = '64F525F8-D2AC-4EF2-83FF-0518CDF896F6';

  final Dio _dio;

  ApiService({
    required String baseUrl,
    String? acceptLanguage,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $staticToken',
                  if (acceptLanguage != null &&
                      acceptLanguage.trim().isNotEmpty)
                    'Accept-Language': acceptLanguage,
                },
              ),
            );

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      final data = response.data;
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

      throw const ApiException('Malformed response: "data" object is missing.');
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  ApiException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 400) {
      final message = _extractErrorMessage(data) ?? 'Bad request.';
      return ApiException(message, statusCode: statusCode);
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Network error. Please check your connection.');
    }

    return ApiException(
      _extractErrorMessage(data) ?? 'Request failed. Please try again.',
      statusCode: statusCode,
    );
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ??
              data['title'] ??
              data['message'] ??
              data['error'])?.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return null;
  }
}
