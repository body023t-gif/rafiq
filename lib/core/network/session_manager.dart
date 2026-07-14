import 'dart:developer' as dev;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/features/auth/presentation/screens/initial_login_screen.dart';
import 'package:rafiq/features/auth/data/models/sign_response.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? accessToken;
  String? refreshToken;
  DateTime? expirationTime;
  String? userId;
  String? studentId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    refreshToken = prefs.getString('refresh_token');
    final exp = prefs.getString('expiration_time');
    if (exp != null) {
      expirationTime = DateTime.tryParse(exp);
    }
    userId = prefs.getString('user_id');
    studentId = prefs.getString('student_id');
  }

  Future<void> saveSession(SignResponse response) async {
    accessToken = response.token;
    refreshToken = response.refreshToken;
    userId = response.id;

    _parseAndSetExpiration(response.expiresIn);

    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null) {
      await prefs.setString('access_token', accessToken!);
    }
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken!);
    }
    if (expirationTime != null) {
      await prefs.setString(
        'expiration_time',
        expirationTime!.toIso8601String(),
      );
    }
    if (userId != null) {
      await prefs.setString('user_id', userId!);
    }
  }

  Future<void> updateTokens(
    String newAccess,
    String? newRefresh,
    dynamic expiresIn,
  ) async {
    accessToken = newAccess;
    if (newRefresh != null && newRefresh.isNotEmpty) {
      refreshToken = newRefresh;
    }

    _parseAndSetExpiration(expiresIn);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken!);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken!);
    }
    if (expirationTime != null) {
      await prefs.setString(
        'expiration_time',
        expirationTime!.toIso8601String(),
      );
    }
  }

  void _parseAndSetExpiration(dynamic expiresIn) {
    if (expiresIn != null) {
      try {
        final seconds = int.parse(expiresIn.toString());
        expirationTime = DateTime.now().add(Duration(seconds: seconds));
      } catch (_) {
        expirationTime = DateTime.now().add(const Duration(hours: 1));
      }
    } else {
      expirationTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

  bool get isTokenExpired {
    if (expirationTime == null) return false;
    // Add a small buffer of 1 minute to refresh proactively
    return DateTime.now().isAfter(
      expirationTime!.subtract(const Duration(minutes: 1)),
    );
  }

  Future<void> logout() async {
    dev.log('[SessionManager] Executing full session logout.');

    accessToken = null;
    refreshToken = null;
    expirationTime = null;
    userId = null;
    studentId = null;

    final prefs = await SharedPreferences.getInstance();

    // Clear session data
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('expiration_time');
    await prefs.remove('user_id');
    await prefs.remove('student_id');

    // Preserve Remember Me credentials if enabled
    final bool rememberMe = prefs.getBool('remember_me') ?? false;
    if (!rememberMe) {
      await prefs.remove('remember_me');
      await prefs.remove('remember_email');
      await prefs.remove('remember_password');
    }

    goTo(const InitialLogin(), canPop: false);
  }
}
