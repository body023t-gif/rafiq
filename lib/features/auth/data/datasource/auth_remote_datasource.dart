import 'package:rafiq/core/network/api_service.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  const AuthRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await apiService.forgotPassword({'email': email});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    return await apiService.resetPassword({
      'email': email,
      'token': token,
      'newPassword': newPassword,
    });
  }
}
