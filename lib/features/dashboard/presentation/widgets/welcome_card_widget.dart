import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class WelcomeCard extends StatelessWidget {
  final String firstName;

  const WelcomeCard({
    super.key,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380.w,
        height: 200.h,
        padding: EdgeInsets.symmetric(
          vertical: 30.h,
          horizontal: 18.w,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFD1E4FA),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // top
          mainAxisAlignment: MainAxisAlignment.spaceBetween,   // left
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "اهلا $firstName!",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "أهلاً بعودتك! خلّينا نرجع\nلدروسك ونواصل التقدّم\nنحو أهدافك.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF5D5F6F),
                  ),
                ),
              ],
            ),
            Image.asset(
              "assets/images/Container.png",
              height: 120.h,
              width: 140.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );



  }
}
