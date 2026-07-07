import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/logic/app_bloc_observer.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/core/ui/snackbar_service.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation_screen.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize SessionManager
    await SessionManager().init();
    
    // Set custom AppBlocObserver
    Bloc.observer = AppBlocObserver();

    // Configure FlutterError.onError
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      const isDebug = !bool.fromEnvironment('dart.vm.product');
      if (isDebug) {
        dev.log('Unhandled Flutter Error: ${details.exception}', stackTrace: details.stack);
      } else {
        SnackbarService.showErrorSnackBar('حدث خطأ غير متوقع في التطبيق.');
      }
    };

    // Configure PlatformDispatcher onError
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      const isDebug = !bool.fromEnvironment('dart.vm.product');
      if (isDebug) {
        dev.log('Unhandled Platform Error: $error', stackTrace: stack);
      } else {
        SnackbarService.showErrorSnackBar('حدث خطأ غير متوقع في التطبيق.');
      }
      return true;
    };

    runApp(const MyApp());
  }, (error, stackTrace) {
    const isDebug = !bool.fromEnvironment('dart.vm.product');
    if (isDebug) {
      dev.log('Unhandled Async Error: $error', stackTrace: stackTrace);
    } else {
      SnackbarService.showErrorSnackBar('حدث خطأ غير متوقع في التطبيق.');
    }
  });
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
        scaffoldMessengerKey: SnackbarService.messengerKey,
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        title: 'Rafiq',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          primaryColor: const Color(0XFF1564BF),
          fontFamily: 'IBMPlexSansArabic',
        ),
        navigatorKey: navigatorKey,
        home: const SplashAnimationView(),
      ),
    );
  }
}
