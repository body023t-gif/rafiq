import 'dart:convert';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:rafiq/core/utils/text_encoding.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:rafiq/data/api/api_exception.dart';

class ApiService {
  static void log(String message) {
    const isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      dev.log(message);
    }
  }

  static const String staticToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkJlYXJlciJ9.eyJ1bmlxdWVfbmFtZSI6IkNvcmRpZV9TYXdheW42NDgiLCJuYW1laWQiOiI1YzdmNmEzOS03MzMxLTQyMmUtYmE4YS01NDE3ZWVkYzAxNzkiLCJlbWFpbCI6IkNvcmRpZV9TYXdheW42NDhAcmFmZWVrLmVkdSIsIm5iZiI6MTc3NzMxOTA1NCwiZXhwIjoxODA4ODU1MDU0LCJqdGkiOiJkODhkNGJiOC1lN2E4LTQ3NmUtYWYxMS01N2E2OWUzN2I1NzIiLCJVc2VyVHlwZXMiOiIxIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJpYXQiOjE3NzczMTkwNTQsImlzcyI6Imh0dHBzOi8vcmFmZWVrLWxpdmUucnVuYXNwLm5ldC8ifQ.2buC9yRUym8kUJv6BZ5oViDQALZo1rpNcFxHUFWwoQg';

  static const String staticUserId = '64F525F8-D2AC-4EF2-83FF-0518CDF896F6';

  static String? get dynamicToken => SessionManager().accessToken;
  static set dynamicToken(String? value) =>
      SessionManager().accessToken = value;

  static String? get dynamicUserId => SessionManager().userId;
  static set dynamicUserId(String? value) => SessionManager().userId = value;

  static String? get dynamicStudentId => SessionManager().studentId;
  static set dynamicStudentId(String? value) =>
      SessionManager().studentId = value;

  static String _maskToken(String? token) {
    if (token == null || token.length < 20) return 'null';
    return '${token.substring(0, 15)}...${token.substring(token.length - 10)}';
  }

  final Dio _dio;
  Dio get dio => _dio;

  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _requestQueue = [];

  ApiService({required String baseUrl, String? acceptLanguage, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 120),
              responseType: ResponseType
                  .bytes, // Force bytes response type for manual UTF-8 decoding
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer ${SessionManager().accessToken}',
                if (acceptLanguage != null && acceptLanguage.trim().isNotEmpty)
                  'Accept-Language': acceptLanguage,
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = SessionManager();
          if (session.accessToken != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          final maskedToken = _maskToken(
            options.headers['Authorization']?.toString(),
          );
          // Extract userId or studentId if present in path or query
          String entityId = '';
          if (options.path.contains('/v1/api/students/dashboard/')) {
            entityId = options.path.split('/').last;
          } else if (options.path.contains('/v1/api/study-plans/student/')) {
            entityId = options.path.split('/').last;
          } else if (options.queryParameters.containsKey('studentId')) {
            entityId = options.queryParameters['studentId']?.toString() ?? '';
          } else if (options.queryParameters.containsKey('StudentId')) {
            entityId = options.queryParameters['StudentId']?.toString() ?? '';
          }

          log('========== Request Trace ==========');
          log('HTTP Method: ${options.method}');
          log('Endpoint URL: ${options.uri}');
          log('Authorization: $maskedToken');
          if (entityId.isNotEmpty) {
            log('ID sent (userId/studentId): $entityId');
          }
          log('Headers: ${options.headers}');
          log('Query Parameters: ${options.queryParameters}');
          log('Request Body: ${options.data}');
          log('===================================');
          options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('========== Response Trace ==========');
          log('Status Code: ${response.statusCode}');
          log('Response Headers: ${response.headers.map}');

          final startTime = response.requestOptions.extra['startTime'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            log('Request Duration: $duration ms');
          }

          if (response.data is List<int>) {
            try {
              final rawString = utf8.decode(response.data as List<int>);
              log('Raw Response Body: $rawString');
            } catch (_) {}
          } else {
            log('Raw Response Body: ${response.data}');
          }

          response.data = _decodeBody(response.data);
          log('Decoded JSON/String: ${response.data}');

          log('===================================');
          return handler.next(response);
        },
        onError: (e, handler) async {
          log('========== Error Trace ==========');
          log('Exception Type: ${e.type}');
          log('Error Message: ${e.message}');
          log('Status Code: ${e.response?.statusCode}');

          if (e.response?.statusCode == 401) {
            final session = SessionManager();
            if (session.refreshToken == null) {
              await session.logout();
              return handler.next(e);
            }

            if (_isRefreshing) {
              log(
                '[Refresh] Refresh in progress. Queuing request: ${e.requestOptions.path}',
              );
              _requestQueue.add({
                'options': e.requestOptions,
                'handler': handler,
              });
              return;
            }

            _isRefreshing = true;
            log('[Refresh] Starting refresh token flow...');
            try {
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: _dio.options.baseUrl,
                  headers: {'Content-Type': 'application/json'},
                ),
              );
              refreshDio.httpClientAdapter = _dio.httpClientAdapter;

              final response = await refreshDio.post(
                '/v1/api/refresh-token',
                data: {'token': session.refreshToken},
              );

              if (response.statusCode == 200 && response.data != null) {
                final data = response.data is String
                    ? json.decode(response.data)
                    : response.data;
                final newToken = data['token'];
                final newRefreshToken = data['refreshToken'];
                final expiresIn = data['expiresIn'];

                if (newToken != null) {
                  log(
                    '[Refresh] Successfully refreshed token. Expiration info: $expiresIn',
                  );
                  await session.updateTokens(
                    newToken,
                    newRefreshToken,
                    expiresIn,
                  );

                  // Retry original request
                  final options = e.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newToken';
                  final cloneReq = await _dio.fetch(options);
                  handler.resolve(cloneReq);

                  // Retry queued requests
                  log(
                    '[Refresh] Retrying ${_requestQueue.length} queued requests.',
                  );
                  for (var req in _requestQueue) {
                    final reqOptions = req['options'] as RequestOptions;
                    final reqHandler =
                        req['handler'] as ErrorInterceptorHandler;
                    reqOptions.headers['Authorization'] = 'Bearer $newToken';
                    try {
                      final clone = await _dio.fetch(reqOptions);
                      reqHandler.resolve(clone);
                    } catch (err) {
                      if (err is DioException) {
                        reqHandler.next(err);
                      }
                    }
                  }
                } else {
                  throw Exception(
                    'Invalid token format from refresh endpoint.',
                  );
                }
              } else {
                throw Exception(
                  'Refresh failed with status ${response.statusCode}',
                );
              }
            } catch (ex) {
              log('[Refresh] Refresh failed: $ex');
              await session.logout();
              return handler.next(e);
            } finally {
              _isRefreshing = false;
              _requestQueue.clear();
            }
            return;
          }
          if (e.response != null) {
            e.response!.data = _decodeBody(e.response!.data);
            log('Error Decoded JSON/String: ${e.response!.data}');
          }

          log('===================================');
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _unwrapObject(response.data, response.statusCode);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _unwrapList(response.data, response.statusCode);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _unwrapObject(response.data, response.statusCode);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return _unwrapObject(response.data, response.statusCode);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data == null) {
        return const {};
      }
      return _unwrapObject(data, response.statusCode);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> body) async {
    final email = body['email']?.toString();
    dev.log('========== [Forgot Password API Request] ==========');
    dev.log('  - Endpoint: POST /v1/api/forgot-password');
    dev.log('  - Email: $email');
    dev.log('===================================================');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/api/forgot-password',
        data: body,
      );
      final data = response.data;
      dev.log('========== [Forgot Password API Response] ==========');
      dev.log('  - Status Code: ${response.statusCode}');
      dev.log('  - Response Body: $data');
      dev.log('====================================================');
      if (data == null) {
        if (response.statusCode == 202 || response.statusCode == 200) {
          return const {'success': true};
        }
        throw const ApiException('Empty response received from server.');
      }
      return _unwrapObject(data, response.statusCode);
    } on DioException catch (e) {
      dev.log('========== [Forgot Password API Error] ==========');
      dev.log('  - Status Code: ${e.response?.statusCode}');
      dev.log('  - Response Body: ${e.response?.data}');
      dev.log('==================================================');
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      dev.log('========== [Forgot Password API Error] ==========');
      dev.log('  - Exception: $e');
      dev.log('==================================================');
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> body) async {
    final email = body['email']?.toString();
    final token = body['token']?.toString();
    dev.log('========== [Reset Password API Request] ==========');
    dev.log('  - Endpoint: POST /v1/api/reset-password');
    dev.log('  - Email: $email');
    dev.log('  - Token: $token');
    dev.log('==================================================');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/api/reset-password',
        data: body,
      );
      final data = response.data;
      dev.log('========== [Reset Password API Response] ==========');
      dev.log('  - Status Code: ${response.statusCode}');
      dev.log('  - Response Body: $data');
      dev.log('===================================================');
      if (data == null) {
        if (response.statusCode == 202 || response.statusCode == 200) {
          return const {'success': true};
        }
        throw const ApiException('Empty response received from server.');
      }
      return _unwrapObject(data, response.statusCode);
    } on DioException catch (e) {
      dev.log('========== [Reset Password API Error] ==========');
      dev.log('  - Status Code: ${e.response?.statusCode}');
      dev.log('  - Response Body: ${e.response?.data}');
      dev.log('=================================================');
      throw _mapDioException(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      dev.log('========== [Reset Password API Error] ==========');
      dev.log('  - Exception: $e');
      dev.log('=================================================');
      throw const ApiException('Unexpected error while calling API.');
    }
  }

  Map<String, dynamic> _unwrapObject(
    Map<String, dynamic>? data,
    int? statusCode,
  ) {
    if (data == null) {
      throw const ApiException('Empty response received from server.');
    }

    final success = data['success'];
    if (success is bool && !success) {
      throw ApiException(
        repairUtf8Text(
          (data['message'] ?? 'Request failed. Please try again.').toString(),
        ),
        statusCode: (data['statusCode'] as num?)?.toInt() ?? statusCode,
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
  }

  List<Map<String, dynamic>> _unwrapList(
    Map<String, dynamic>? data,
    int? statusCode,
  ) {
    if (data == null) {
      throw const ApiException('Empty response received from server.');
    }

    final success = data['success'];
    if (success is bool && !success) {
      throw ApiException(
        repairUtf8Text(
          (data['message'] ?? 'Request failed. Please try again.').toString(),
        ),
        statusCode: (data['statusCode'] as num?)?.toInt() ?? statusCode,
      );
    }

    final innerData = data['data'];
    if (innerData is List) {
      return innerData
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (innerData is Map<String, dynamic>) {
      for (final key in [
        'items',
        'courses',
        'sessions',
        'messages',
        'results',
      ]) {
        final value = innerData[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
      return [innerData];
    }

    if (innerData == null && success == true) {
      return const [];
    }

    throw const ApiException('Malformed response: "data" list is missing.');
  }

  ApiException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    log('========== [Dio Error Trace] ==========');
    log('  - DioException.type: ${e.type}');
    log('  - HTTP Status Code: $statusCode');
    log('  - Message: ${e.message}');
    log('  - StackTrace: ${e.stackTrace}');

    if (data != null) {
      final decoded = _decodeBody(data);
      log('  - Backend Raw Response Object: $decoded');
      if (decoded is Map<String, dynamic>) {
        final msg =
            decoded['message'] ??
            decoded['detail'] ??
            decoded['title'] ??
            decoded['error'];
        if (msg != null) {
          log('  - Backend Message: ${repairUtf8Text(msg.toString())}');
        }

        final errors = decoded['errors'] ?? decoded['Errors'];
        if (errors != null) {
          log('  - Backend Errors Object: $errors');
        }
      }
    }
    log('========================================');

    // 1. Map Timeouts and network connection failures
    if (e.type == DioExceptionType.connectionTimeout) {
      return const ApiException('انتهت مهلة الاتصال بالخادم.');
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return const ApiException('الخادم استغرق وقتاً أطول من المتوقع.');
    }
    if (e.type == DioExceptionType.sendTimeout) {
      return const ApiException('تعذر إرسال الطلب.');
    }
    if (e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown &&
            e.error != null &&
            e.error.toString().contains('SocketException'))) {
      return const ApiException('لا يوجد اتصال بالإنترنت.');
    }

    // 2. Map standard HTTP Status codes
    if (statusCode == 500) {
      return const ApiException(
        'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً.',
        statusCode: 500,
      );
    }

    if (statusCode == 403) {
      return const ApiException(
        'ليس لديك صلاحية لتنفيذ هذه العملية.',
        statusCode: 403,
      );
    }
    if (statusCode == 404) {
      return const ApiException('الخدمة غير متوفرة.', statusCode: 404);
    }

    // 3. Extract backend message for other statuses (e.g. 400, 409)
    final backendMsg = _extractErrorMessage(data);
    if (backendMsg != null && backendMsg.trim().isNotEmpty) {
      return ApiException(repairUtf8Text(backendMsg), statusCode: statusCode);
    }

    if (statusCode == 400) {
      return const ApiException(
        'طلب غير صالح. يرجى التحقق من المدخلات.',
        statusCode: 400,
      );
    }
    if (statusCode == 409) {
      return const ApiException('حدث تعارض في البيانات.', statusCode: 409);
    }

    return ApiException(
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      statusCode: statusCode,
    );
  }

  String? _translateValidationError(String fieldName, String errorCode) {
    final code = errorCode.trim();
    final field = fieldName.toLowerCase();

    if (field == 'notes' || field == 'description') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required') ||
          code.isEmpty) {
        return 'يرجى إدخال سبب أو ملاحظات قبل إرسال الطلب.';
      }
    }
    if (field == 'appointmentdate') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required')) {
        return 'يرجى اختيار تاريخ الموعد.';
      }
    }
    if (field == 'time') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required')) {
        return 'يرجى اختيار وقت الموعد.';
      }
    }
    if (field == 'servicetype') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required')) {
        return 'يرجى اختيار نوع الخدمة.';
      }
    }
    if (field == 'studentid') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required')) {
        return 'يرجى التأكد من تسجيل الدخول كطالب.';
      }
    }
    if (field == 'title') {
      if (code == 'RequiredField_Msg' ||
          code.toLowerCase().contains('required')) {
        return 'يرجى إدخال عنوان الطلب.';
      }
    }
    return null;
  }

  String? _parseValidationErrors(dynamic errors) {
    final List<String> messages = [];
    if (errors is Map<String, dynamic>) {
      errors.forEach((key, value) {
        if (value is List) {
          for (var item in value) {
            final itemStr = item.toString().trim();
            final translated = _translateValidationError(key, itemStr);
            messages.add(translated ?? repairUtf8Text(itemStr));
          }
        } else if (value != null) {
          final valStr = value.toString().trim();
          final translated = _translateValidationError(key, valStr);
          messages.add(translated ?? repairUtf8Text(valStr));
        }
      });
    } else if (errors is List) {
      for (var item in errors) {
        if (item != null) {
          messages.add(repairUtf8Text(item.toString()));
        }
      }
    } else if (errors != null) {
      messages.add(repairUtf8Text(errors.toString()));
    }
    if (messages.isNotEmpty) {
      return messages.join('\n');
    }
    return null;
  }

  String? _extractErrorMessage(dynamic data) {
    final decoded = _decodeBody(data);
    if (decoded is Map<String, dynamic>) {
      // 1. Prioritize validation errors over generic backend messages
      final errors = decoded['errors'] ?? decoded['Errors'];
      if (errors != null) {
        final parsedErrors = _parseValidationErrors(errors);
        if (parsedErrors != null && parsedErrors.trim().isNotEmpty) {
          return parsedErrors;
        }
      }

      // 2. Fallback to generic message / detail / title / error
      final message =
          (decoded['message'] ??
                  decoded['detail'] ??
                  decoded['title'] ??
                  decoded['error'])
              ?.toString();
      if (message != null) {
        return repairUtf8Text(message);
      }
    } else if (decoded is String && decoded.trim().isNotEmpty) {
      return repairUtf8Text(decoded);
    }
    return null;
  }

  dynamic _decodeBody(dynamic data) {
    if (data == null) return null;

    if (data is List<int>) {
      try {
        final decodedString = utf8.decode(data);
        try {
          return json.decode(decodedString);
        } catch (_) {
          return repairUtf8Text(decodedString);
        }
      } catch (_) {}
    }

    if (data is String) {
      return repairUtf8Text(data);
    }

    return data;
  }
}
