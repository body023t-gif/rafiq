
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:rafiq/features/user_profile/presentation/widgets/academichistory/cubit/model.dart';
class AcademicHistoryView extends StatelessWidget {
  final List<SemesterModel> semesters;

  const AcademicHistoryView({
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
                        "GPA: ${semester.gpa.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1564BF),
                        ),
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
                            Text(course.code),
                            const Spacer(),
                            Text("${course.creditHours} ساعات"),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(course.name),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  "${course.degree}",
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
