import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/ui/appbar.dart';

class CollegeBuildingMapScreen extends StatelessWidget {
  const CollegeBuildingMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> floors = [
      {
        "title": "الطابق الأول",
        "subtitle": "كلية الحاسبات والمعلومات",
        "description": "يحتوي على شؤون الطلاب، المكاتب الإدارية، والمدرجات الكبرى 1 و 2.",
      },
      {
        "title": "الطابق الثاني",
        "subtitle": "كلية الحاسبات والمعلومات",
        "description": "يحتوي على معامل الحاسب الآلي (201-205)، ومكاتب أعضاء هيئة التدريس لقسم علوم الحاسب.",
      },
      {
        "title": "الطابق الثالث",
        "subtitle": "كلية الحاسبات والمعلومات",
        "description": "يحتوي على معامل الشبكات والذكاء الاصطناعي، وقاعة المؤتمرات، ومكتب عميد الكلية.",
      },
      {
        "title": "الطابق الرابع",
        "subtitle": "كلية الحاسبات والمعلومات",
        "description": "يحتوي على المكتبة المركزية، وصالة المطالعة، ومكاتب الدراسات العليا.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: const CustomAppBar(title: "خريطة مبنى الكلية"),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.separated(
          padding: EdgeInsets.all(20.w),
          itemCount: floors.length,
          separatorBuilder: (_, __) => SizedBox(height: 20.h),
          itemBuilder: (context, index) {
            final floor = floors[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Simple clean UI container
                  Container(
                    width: double.infinity,
                    height: 180.h,
                    margin: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD1E4FA)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/map_${index + 1}.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  // Text Details
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      children: [
                        Text(
                          floor['title']!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          floor['subtitle']!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          floor['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            height: 1.5.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
