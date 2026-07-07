import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/auth/data/models/sign_response.dart';

class MockAdapter implements HttpClientAdapter {
  int requestCount = 0;
  int refreshCount = 0;
  bool failRefresh = false;
  List<String> authorizedRequests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    requestCount++;
    
    if (options.path == '/v1/api/refresh-token') {
      refreshCount++;
      if (failRefresh) {
        return ResponseBody.fromString(
          '{"message": "Invalid token"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      final data = {
        'token': 'new_access_token_123',
        'refreshToken': 'new_refresh_token_456',
        'expiresIn': 3600,
      };
      return ResponseBody.fromString(
        json.encode(data),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    
    final authHeader = options.headers['Authorization'];
    if (authHeader == 'Bearer valid_access_token' || authHeader == 'Bearer new_access_token_123') {
      authorizedRequests.add(authHeader);
      return ResponseBody.fromString(
        '{"success": true, "data": "dummy"}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    
    return ResponseBody.fromString(
      '{"message": "Unauthorized"}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAdapter mockAdapter;
  late ApiService apiService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager().init();
    mockAdapter = MockAdapter();
    apiService = ApiService(baseUrl: 'https://example.com');
    apiService.dio.httpClientAdapter = mockAdapter;
  });

  test('Scenario 1: Login Successfully', () async {
    final response = SignResponse(
      id: 'user123',
      token: 'valid_access_token',
      refreshToken: 'valid_refresh_token',
      expiresIn: 3600,
    );
    await SessionManager().saveSession(response);
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), 'valid_access_token');
    expect(prefs.getString('refresh_token'), 'valid_refresh_token');
    expect(prefs.getString('user_id'), 'user123');
    expect(SessionManager().accessToken, 'valid_access_token');
    
    print('Scenario 1 Passed: Session stored correctly.');
  });

  test('Scenario 2: Authenticated API uses latest token', () async {
    await SessionManager().saveSession(SignResponse(token: 'valid_access_token', expiresIn: 3600));
    await apiService.get('/dummy-endpoint');
    expect(mockAdapter.authorizedRequests.contains('Bearer valid_access_token'), true);
    print('Scenario 2 Passed: Request used the latest token.');
  });

  test('Scenario 3: Force 401 & Queueing', () async {
    await SessionManager().saveSession(SignResponse(token: 'expired_token', refreshToken: 'valid_refresh_token', expiresIn: 0));
    
    // Fire 3 simultaneous requests
    final futures = [
      apiService.get('/req1'),
      apiService.get('/req2'),
      apiService.get('/req3'),
    ];
    
    await Future.wait(futures);
    
    expect(mockAdapter.refreshCount, 1);
    expect(mockAdapter.authorizedRequests.length, 3);
    expect(mockAdapter.authorizedRequests.every((t) => t == 'Bearer new_access_token_123'), true);
    print('Scenario 3 Passed: Only one refresh request made, all requests queued and retried with new token.');
  });

  test('Scenario 4: Force refresh failure', () async {
    await SessionManager().saveSession(SignResponse(token: 'expired_token', refreshToken: 'bad_refresh_token', expiresIn: 0));
    mockAdapter.failRefresh = true;
    
    try {
      await apiService.get('/req1');
    } catch (_) {}
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), null);
    expect(prefs.getString('refresh_token'), null);
    expect(SessionManager().accessToken, null);
    
    print('Scenario 4 Passed: Session cleared on refresh failure.');
  });

  test('Scenario 5: Manual Logout', () async {
    await SessionManager().saveSession(SignResponse(token: 'valid_token', expiresIn: 3600));
    await SessionManager().logout();
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), null);
    expect(SessionManager().accessToken, null);
    print('Scenario 5 Passed: Manual logout cleared session.');
  });

  test('Scenario 6: Restart application logic', () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'saved_token',
      'refresh_token': 'saved_refresh',
      'expiration_time': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    });
    final manager = SessionManager();
    // Simulate restart by initializing again
    await manager.init();
    expect(manager.accessToken, 'saved_token');
    print('Scenario 6 Passed: Restart restored session correctly.');
  });

  test('Scenario 7: Multiple parallel requests while expiring', () async {
    await SessionManager().saveSession(SignResponse(token: 'expired_token', refreshToken: 'valid_refresh_token', expiresIn: 0));
    final futures = List.generate(10, (i) => apiService.get('/test$i'));
    await Future.wait(futures);
    expect(mockAdapter.refreshCount, 1); // should only trigger refresh once
    expect(mockAdapter.authorizedRequests.length, 10);
    print('Scenario 7 Passed: 10 parallel requests successfully queued and resolved.');
  });
}
