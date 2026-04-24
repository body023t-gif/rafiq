import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/profile/models/profile_model.dart';

class AcademicHistoryWidget extends StatelessWidget {
  final List<AcademicHistoryModel> semesters;

  const AcademicHistoryWidget({
    super.key,
    required this.semesters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: const Color(0xFFE8F2FC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "التاريخ الأكاديمي",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ...semesters.map((semester) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        semester.semesterName,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999.r),
                        color: const Color(0xFFA3C9F5),
                      ),
                      child: Text(
                        "GPA: ${semester.semesterGpa.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1564BF)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                ...semester.courses.map((course) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: const Color(0xFFFDFDFC),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(course.courseCode),
                            const Spacer(),
                            Text("${course.creditHours} ساعات"),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(child: Text(course.courseTitle)),
                            Row(
                              children: [
                                Text(
                                  "${course.score}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1564BF),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  course.grade,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1564BF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 8.h),
              ],
            );
          }),
        ],
      ),
    );
  }
}
