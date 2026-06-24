import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        title: 'Rafiq',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          primaryColor: const Color(0XFF1564BF),
          fontFamily: 'IBMPlexSansArabic',
        ),
        navigatorKey: navigatorKey,
        home: DashboardScreen(
  userId: "3db62f5c-1cc5-46a1-a1c6-19e5b04fd0fa",
),
        // PageView(
        //   children: [
        //     const CoursesView(),
        //     const WelcomeChatView(),
        //     DashboardScreen(userId: ApiService.staticUserId),
        //     const SplashAnimationView(),
        //     const SplashAnimation2View(),
        //     const ProfileScreen(),
        //   ],
        // ),
      ),
    );
  }
}
