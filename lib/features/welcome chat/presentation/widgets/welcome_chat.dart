import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/chat%20ai/presentation/widgets/chat%20ai.dart';

class WelcomeChatView extends StatelessWidget {
  const WelcomeChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الشات الذكى'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 120.h),
            Image.asset('assets/images/message_empty.png'),
            SizedBox(height: 32.h),
            const Text(
              'ابدأ أول محادثة لك مع المرشد الأكاديمي',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 32.h),
            CustomFilledButton(
              text: 'بدء الدردشة',
              width: double.infinity,
              height: 46.h,
              radius: 14.r,
              onPressed: () => goTo(const ChatAIView()),
            ),
          ],
        ),
      ),
    );
  }
}
