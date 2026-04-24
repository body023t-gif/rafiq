import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgressItem extends StatelessWidget {
  final String title;
  final double percent;
  final Color color;

  const ProgressItem({
    super.key,
    required this.title,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${(percent * 100).toInt()}%",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),

        SizedBox(height: 6.h),

        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8.h,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),

        SizedBox(height: 12.h),
      ],
    );
  }
}
class PlanProgressCard extends StatelessWidget {
  final int completedCourses;
  final int remainingCourses;
  final double universityRequirementsPercentage;
  final double majorRequirementsPercentage;
  final double electiveRequirementsPercentage;

  const PlanProgressCard({
    super.key,
    required this.completedCourses,
    required this.remainingCourses,
    required this.universityRequirementsPercentage,
    required this.majorRequirementsPercentage,
    required this.electiveRequirementsPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 335.w,
      //height: 350.h,
      padding: EdgeInsets.only(
        top: 20.h,
        bottom: 20.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD1E4FA),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: Color(0xff1564BF),
              ),
              const SizedBox(width: 2),
              Text(
                "تقدم فى الخطة",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h,),
          Row(
            children: [
              Expanded(
                child: Container(
                  //height: 74,
                  padding: EdgeInsets.only(
                    top: 14.h,
                    bottom: 14.h,
                    left: 14.w,
                    right: 14.w,
                  ),

                  decoration: BoxDecoration(
                    color: Color(0xff1564BF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                      '$completedCourses',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4,),
                    Text(
                      "مقرر مكتمل",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],),
                ),
              ),
               SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  //height: 74,
                  padding: EdgeInsets.only(
                    top: 14.h,
                    bottom: 14.h,
                    left: 14.w,
                    right: 14.w,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                    Text(
                      '$remainingCourses',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4,),
                    Text(
                      "مقرر متبقى",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h,),

          ProgressItem(
            title: "متطلبات الجامعة",
            percent: universityRequirementsPercentage.clamp(0.0, 1.0),
            color: Colors.green,
          ),

          ProgressItem(
            title: "متطلبات التخصص",
            percent: majorRequirementsPercentage.clamp(0.0, 1.0),
            color: Color(0xff1564BF),
          ),

          ProgressItem(
            title: "المقررات الاختيارية",
            percent: electiveRequirementsPercentage.clamp(0.0, 1.0),
            color: Colors.red,
          ),

        ],
      ),
    );
  }
}