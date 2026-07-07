import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation2_screen.dart';
import 'package:rafiq/features/auth/presentation/screens/initial_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:rafiq/features/dashboard/presentation/screens/home_screen.dart';
class SplashAnimationView extends StatefulWidget {
  const SplashAnimationView({super.key});

  @override
  State<SplashAnimationView> createState() => _SplashAnimationViewState();
}

class _SplashAnimationViewState extends State<SplashAnimationView> {
  final int splashDurationSeconds = 2;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    // Check session
    final bool hasValidSession = SessionManager().accessToken != null && !SessionManager().isTokenExpired;

    Future.delayed(Duration(seconds: splashDurationSeconds), () {
      if (!mounted) return;
      if (hasValidSession) {
        // Valid session exists, go straight to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (onboardingCompleted) {
        // No session but onboarding done, go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitialLogin()),
        );
      } else {
        // New user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashAnimation2View()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1564BF),
      body: Center(
        child: BackInDown(
          duration: Duration(seconds: splashDurationSeconds),
          child: Image.asset(
            "assets/images/Rafiq_logo_white.png",
            height: 400.h,
            width: 400.w,
          ),
        ),
      ),
    );
  }
}