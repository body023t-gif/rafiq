import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'package:rafiq/features/auth/data/models/sign_in_command.dart';
import 'package:dio/dio.dart';

// Provide your actual test credentials via environment variables when running this test
// e.g., flutter test test/real_backend_test.dart --dart-define=TEST_EMAIL=... --dart-define=TEST_PASS=...
const String testEmail = String.fromEnvironment('TEST_EMAIL', defaultValue: 'admin@rafeek.edu');
const String testPassword = String.fromEnvironment('TEST_PASS', defaultValue: 'Password123!');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late ApiService apiService;
  late AuthRepository authRepository;

  setUpAll(() async {
    // Allow real network requests in flutter test
    HttpOverrides.global = null;
    
    // Setup Mock SharedPreferences for the SessionManager inside a test environment
    SharedPreferences.setMockInitialValues({});
    await SessionManager().init();
    
    // Initialize services connected to the LIVE backend
    apiService = ApiService(baseUrl: 'https://rafeek-live.runasp.net');
    authRepository = AuthRepository(dio: apiService.dio);
  });

  test('Real Backend Integration Test - Auth Refresh Flow', () async {
    print('==================================================');
    print('1. Login');
    print('==================================================');
    
    final command = SignInCommand(email: testEmail, password: testPassword);
    final signResponse = await authRepository.login(command);
    
    print('Login Response:');
    print('- User ID: ${signResponse.id}');
    print('- Token exists: ${signResponse.token != null}');
    print('- Refresh Token exists: ${signResponse.refreshToken != null}');
    
    expect(signResponse.token, isNotNull);
    expect(signResponse.refreshToken, isNotNull);

    print('==================================================');
    print('2-4. Store Tokens & Decode Expiration');
    print('==================================================');
    
    await SessionManager().saveSession(signResponse);
    final session = SessionManager();
    
    expect(session.accessToken, signResponse.token);
    expect(session.refreshToken, signResponse.refreshToken);
    expect(session.expirationTime, isNotNull);
    
    final originalAccessToken = session.accessToken!;
    final originalRefreshToken = session.refreshToken!;
    
    print('Stored Access Token: ${originalAccessToken.substring(0, 15)}... (masked)');
    print('Stored Refresh Token: ${originalRefreshToken.substring(0, 15)}... (masked)');
    print('Expiration Time: ${session.expirationTime}');
    
    print('==================================================');
    print('5. Force token expiration and simulate 401');
    print('==================================================');
    
    // We intentionally corrupt the access token in SessionManager to trigger a 401
    // when calling a protected endpoint (e.g. user profile)
    session.accessToken = 'corrupted_token_to_force_401';
    
    print('Making request to /v1/api/profile with corrupted token to force 401...');
    
    // The interceptor should catch the 401, execute POST /v1/api/refresh-token
    // with the valid refresh token, update SessionManager, and retry the request.
    try {
      final profileResponse = await apiService.get('/v1/api/profile'); // Adjust endpoint if needed
      print('Request succeeded after interceptor handled 401! Response keys: ${profileResponse.keys}');
    } catch (e) {
      if (e is DioException) {
         print('Request failed with DioException: ${e.response?.statusCode}');
      } else {
         print('Request failed: $e');
      }
    }
    
    print('==================================================');
    print('6-9. Verify Refresh Flow and Retries');
    print('==================================================');
    
    // After the interceptor completes, the SessionManager should have NEW tokens
    print('New Access Token in SessionManager: ${session.accessToken?.substring(0, 15)}... (masked)');
    print('New Refresh Token in SessionManager: ${session.refreshToken?.substring(0, 15)}... (masked)');
    
    expect(session.accessToken, isNot(originalAccessToken));
    expect(session.accessToken, isNot('corrupted_token_to_force_401'));
    // The backend might or might not issue a new refresh token. Usually it does.
    
    print('==================================================');
    print('10. Verify refresh failure logs the user out');
    print('==================================================');
    
    // Corrupt the refresh token as well
    session.refreshToken = 'bad_refresh_token_to_force_refresh_failure';
    session.accessToken = 'corrupted_token_to_force_401';
    
    print('Making request with corrupted access and refresh tokens...');
    try {
      await apiService.get('/v1/api/profile');
      fail('Request should have failed');
    } catch (e) {
      print('Caught expected failure. Verifying session is cleared...');
    }
    
    // Verify session is cleared (Note: goTo UI function will fail in tests, so we just check prefs)
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access_token'), isNull);
    expect(session.accessToken, isNull);
    print('Session successfully wiped on refresh failure.');
  });
}
