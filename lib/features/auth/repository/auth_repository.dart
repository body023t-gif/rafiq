import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:rafiq/features/auth/data/models/sign_in_command.dart';
import 'package:rafiq/features/auth/data/models/reset_password_command.dart';
import 'package:rafiq/features/auth/data/models/sign_response.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:rafiq/core/network/api_client.dart';

class AuthRepository {
  final Dio _dio;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({Dio? dio, AuthRemoteDataSource? remoteDataSource})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'https://rafeek-live.runasp.net',
              ),
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )),
        remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(createApiService());

  Future<SignResponse> login(SignInCommand command) async {
    try {
      final response = await _dio.post(
        '/v1/api/signin',
        data: command.toJson(),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw const ApiException('Empty response from server.');
      }

      // Handle both wrapped {"success": true, "data": {...}} and raw responses
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('success') && responseData.containsKey('data')) {
          final success = responseData['success'];
          if (success is bool && !success) {
            throw ApiException(responseData['message'] ?? 'Login failed.');
          }
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            return SignResponse.fromJson(data);
          }
        }
        return SignResponse.fromJson(responseData);
      }

      throw const ApiException('Unexpected response format.');
    } on DioException catch (e) {
      final data = e.response?.data;
      final statusCode = e.response?.statusCode;
      log('DEBUG [AuthRepository]: DioException caught.');
      log('DEBUG [AuthRepository]: Status Code = $statusCode');
      log('DEBUG [AuthRepository]: Raw response data = $data');

      String message = 'Login failed.';
      if (data is Map<String, dynamic>) {
        if (e.response?.statusCode == 400 && data.containsKey('errors')) {
          final errors = data['errors'];
          log('DEBUG [AuthRepository]: Parsed errors map = $errors');
          if (errors is Map<String, dynamic> && errors.containsKey('email')) {
            final emailErrors = errors['email'];
            log('DEBUG [AuthRepository]: email errors = $emailErrors');
            if (emailErrors != null && (emailErrors is! List || emailErrors.isNotEmpty)) {
              final apiEx = ApiException('Email is not activated yet.', statusCode: 400);
              log('DEBUG [AuthRepository]: Throwing structural activation Exception: $apiEx');
              throw apiEx;
            }
          }
        }
        message = data['message'] ?? data['detail'] ?? data['error'] ?? message;
      }
      final apiEx = ApiException(message, statusCode: statusCode);
      log('DEBUG [AuthRepository]: Throwing general Exception: $apiEx');
      throw apiEx;
    } catch (e) {
      log('DEBUG [AuthRepository]: Generic exception caught: $e');
      final apiEx = ApiException(e.toString());
      log('DEBUG [AuthRepository]: Throwing generic Exception: $apiEx');
      throw apiEx;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<bool> resetPassword(ResetPasswordCommand command) async {
    try {
      await remoteDataSource.resetPassword(
        email: command.email ?? '',
        token: command.token ?? '',
        newPassword: command.newPassword ?? '',
      );
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
