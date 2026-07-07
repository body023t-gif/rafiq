import re
import json

with open('d:/Graduation_Project/lib/data/api/api_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add SessionManager import
content = content.replace("import 'package:rafiq/core/utils/text_encoding.dart';", "import 'package:rafiq/core/utils/text_encoding.dart';\nimport 'package:rafiq/core/network/session_manager.dart';")

# 2. Remove static fields from ApiService
content = re.sub(r'static const String staticToken =.*?;\n\s*static const String staticUserId =.*?;\n\s*static String\? dynamicToken;\n\s*static String\? dynamicUserId;\n\s*static String\? dynamicStudentId;', 'static const String staticUserId = \'64F525F8-D2AC-4EF2-83FF-0518CDF896F6\';', content, flags=re.DOTALL)

# 3. Add refresh token queue state
content = re.sub(r'final Dio _dio;\n\s*Dio get dio => _dio;', 'final Dio _dio;\n  Dio get dio => _dio;\n\n  bool _isRefreshing = false;\n  final List<Map<String, dynamic>> _requestQueue = [];', content)

# 4. Modify BaseOptions Authorization
content = re.sub(r'\'Authorization\': \'Bearer \$\{dynamicToken \?\? staticToken\}\',', '\'Authorization\': \'Bearer \$\{SessionManager().accessToken\}\',', content)

# 5. Modify onRequest
on_request_new = '''onRequest: (options, handler) async {
        final session = SessionManager();
        if (session.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }'''
content = re.sub(r'onRequest: \(options, handler\) \{[^\}]*?if \(dynamicToken != null\) \{.*?\}.*?final maskedToken', on_request_new + '\n        final maskedToken', content, flags=re.DOTALL)

# 6. Modify onError interceptor to handle 401
on_error_new = '''onError: (e, handler) async {
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
            log('[Refresh] Refresh in progress. Queuing request: ${e.requestOptions.path}');
            _requestQueue.add({
              'options': e.requestOptions,
              'handler': handler,
            });
            return;
          }
          
          _isRefreshing = true;
          log('[Refresh] Starting refresh token flow...');
          try {
            final refreshDio = Dio(BaseOptions(
              baseUrl: _dio.options.baseUrl,
              headers: {'Content-Type': 'application/json'},
            ));
            
            final response = await refreshDio.post(
              '/v1/api/refresh-token',
              data: {'token': session.refreshToken},
            );
            
            if (response.statusCode == 200 && response.data != null) {
              final data = response.data is String ? json.decode(response.data) : response.data;
              final newToken = data['token'];
              final newRefreshToken = data['refreshToken'];
              final expiresIn = data['expiresIn'];
              
              if (newToken != null) {
                log('[Refresh] Successfully refreshed token. Expiration info: $expiresIn');
                await session.updateTokens(newToken, newRefreshToken, expiresIn);
                
                // Retry original request
                final options = e.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                final cloneReq = await _dio.fetch(options);
                handler.resolve(cloneReq);
                
                // Retry queued requests
                log('[Refresh] Retrying ${_requestQueue.length} queued requests.');
                for (var req in _requestQueue) {
                  final reqOptions = req['options'] as RequestOptions;
                  final reqHandler = req['handler'] as ErrorInterceptorHandler;
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
                throw Exception('Invalid token format from refresh endpoint.');
              }
            } else {
              throw Exception('Refresh failed with status ${response.statusCode}');
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
        }'''
content = re.sub(r'onError: \(e, handler\) \{.*?(?=if \(e.response != null\))', on_error_new + '\n        ', content, flags=re.DOTALL)

# 7. Remove 401 handling from _mapDioException
content = re.sub(r'if \(statusCode == 401\) \{.*?return const ApiException\([^;]+;\n\s*\}', '', content, flags=re.DOTALL)

with open('d:/Graduation_Project/lib/data/api/api_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
