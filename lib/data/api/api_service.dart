import 'package:dio/dio.dart';
import 'package:rafiq/data/api/api_exception.dart';

class ApiService {
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

      return data;
    } on DioException catch (e) {
      throw _mapDioException(e);
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
      return (data['detail'] ?? data['title'] ?? data['message'])?.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return null;
  }
}
