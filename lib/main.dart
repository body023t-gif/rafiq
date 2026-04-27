import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rafiq/features/profile/presentation/screens/profile_screen.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation_screen.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation2_screen.dart';
import 'core/logic/helper_method.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //static const String _fontFamily = 'IBMPlexSansArabic';


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:(context, child)=>MaterialApp(
        debugShowCheckedModeBanner: false,
      
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
      
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          primaryColor: Color(0XFF1564BF),
            fontFamily: 'IBMPlexSansArabic',

          //fontFamily: _fontFamily,
        ),

        // theme: ThemeData(
        //   scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        //   primaryColor: Color(0XFF1564BF),
        //   fontFamily: 'IBMPlexSansArabic',
        //   textTheme: const TextTheme(
        //     bodyMedium: TextStyle(
        //       fontFamilyFallback: ['IBMPlexSans'],
        //       fontSize: 16,
        //       fontWeight: FontWeight.w400,
        //     ),
        //   ),
        // ),
      
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        navigatorKey: navigatorKey,

        home: PageView(
          scrollDirection: Axis.vertical,
          children: [
            const DashboardScreen(userId: '00000000-0000-0000-0000-000000000000'),
            const SplashAnimationView(),
            const SplashAnimation2View(),
            const ProfileScreen(),
      
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
