import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/courses.dart';
import 'package:rafiq/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rafiq/features/profile/presentation/screens/profile_screen.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation_screen.dart';
import 'package:rafiq/features/splash/presentation/screens/splash_animation2_screen.dart';
import 'package:rafiq/features/welcome%20chat/presentation/widgets/welcome_chat.dart';
import 'package:rafiq/core/logic/helper_method.dart';

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
      builder:(context, child)=>MaterialApp(
        debugShowCheckedModeBanner: false,
      
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
      
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          primaryColor: Color(0XFF1564BF),
            fontFamily: 'IBMPlexSansArabic',

        ),


        navigatorKey: navigatorKey,

        home: PageView(
          children: [
            CoursesView(),
            const WelcomeChatView(),
            const DashboardScreen(userId: '3db62f5c-1cc5-46a1-a1c6-19e5b04fd0fa'),
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
// This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
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
