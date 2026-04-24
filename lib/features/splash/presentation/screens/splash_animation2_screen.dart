// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:rafiq/core/logic/helper_method.dart';
//
// class SplashAnimation2View extends StatefulWidget {
//   const SplashAnimation2View({super.key});
//
//   @override
//   State<SplashAnimation2View> createState() => _SplashScreenFigmaState();
// }
//
// class _SplashScreenFigmaState extends State<SplashAnimation2View>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//
//     _animation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     );
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenW = 1.sw;
//     final screenH = 1.sh;
//     final buttonHeight = 58.h;
//
//     return Scaffold(
//       body: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned(
//             top: -screenH * 0.4,
//             left: -screenW * 0.3,
//             child: Container(
//               width: screenW * 2,
//               height: screenH * 1.4,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF1564BF),
//                 borderRadius: BorderRadius.circular(screenW),
//               ),
//             ),
//           ),
//
//           Center(
//             child: Image.asset(
//               "assets/images/Rafiq_logo_white.png",
//               width: screenW * 1.2,
//               height: screenH * 0.55,
//               fit: BoxFit.contain,
//             ),
//           ),
//
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               final whiteHeight = screenH * 0.30;
//               final whiteBottom = -whiteHeight * (1 - _animation.value);
//
//               return Stack(
//                 children: [
//                   Positioned(
//                     bottom: whiteBottom,
//                     child: Container(
//                       width: screenW,
//                       height: whiteHeight,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(40.r),
//                           topRight: Radius.circular(40.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: whiteBottom + whiteHeight / 2 - 29.h,
//                     left: 0,
//                     right: 0,
//                     child: Center(
//                       child: SizedBox(
//                         width: 211.w,
//                         height: 58.h,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // الأكشن هنا
//                             goTo(const ProfileView());
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF1564BF),
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30.r),
//                             ),
//                           ),
//                           child: Text(
//                             'التالي',
//                             // style: TextStyle(
//                             //   color: Colors.white,
//                             //   fontSize: 18.sp,
//                             //   fontWeight: FontWeight.bold,
//                             // ),
//                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/features/profile/presentation/screens/profile_screen.dart';

class SplashAnimation2View extends StatefulWidget {
  const SplashAnimation2View({super.key});

  @override
  State<SplashAnimation2View> createState() => _SplashAnimation2ViewState();
}

class _SplashAnimation2ViewState extends State<SplashAnimation2View>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = 1.sw;
    final screenH = 1.sh;
    final whiteHeight = screenH * 0.30;

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -screenH * 0.4,
            left: -screenW * 0.3,
            child: Container(
              width: screenW * 2,
              height: screenH * 1.4,
              decoration: BoxDecoration(
                color: const Color(0xFF1564BF),
                borderRadius: BorderRadius.circular(screenW),
              ),
            ),
          ),

          Center(
            child: Image.asset(
              "assets/images/Rafiq_logo_white.png",
              width: screenW * 0.8,
              fit: BoxFit.contain,
            ),
          ),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final whiteBottom = -whiteHeight * (1 - _animation.value);

              return Stack(
                children: [
                  Positioned(
                    bottom: whiteBottom,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenW,
                      height: whiteHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.r),
                          topRight: Radius.circular(40.r),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: whiteBottom + (whiteHeight / 2) - 29.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 211.w,
                        height: 58.h,
                        child: ElevatedButton(
                          onPressed: () {
                             goTo(
                               const ProfileScreen(),
                             );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1564BF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                           child: Text(
                             'التالي',
                             style: TextStyle(
                               fontFamily: 'IBMPlexSansArabic',                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}