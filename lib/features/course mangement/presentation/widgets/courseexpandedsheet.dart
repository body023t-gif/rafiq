import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/logic/helper_method.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/course%20mangement/models/course_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/schedule.dart';

class CourseExpandedSheet extends StatelessWidget {
  final CourseItemModel course;

  const CourseExpandedSheet({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final sections = course.sections.isNotEmpty
        ? course.sections
        : [
            CourseSectionModel(
              id: course.id,
              sectionName: 'Section A1',
              instructorName: course.instructorName,
              scheduleTime: course.scheduleTime,
              availableSeats: course.availableSeats,
              totalSeats: course.totalSeats,
            ),
          ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            course.courseCode,
            style: TextStyle(
              color: const Color(0xFF1564BF),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            course.courseTitle,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildTag('${course.creditHours} CREDITS'),
              SizedBox(width: 8.w),
              if (course.requirementType.isNotEmpty)
                _buildTag(course.requirementType.toUpperCase()),
            ],
          ),
          SizedBox(height: 24.h),
          ...sections.map(
            (section) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SectionCard(
                sectionName: section.sectionName,
                taName: section.instructorName,
                time: section.scheduleTime,
                seats: section.seatsLabel,
                isFull: section.isFull,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          CustomFilledButton(
            text: 'اضف إلى الجدول',
            width: double.infinity,
            height: 48.h,
            radius: 14.r,
            onPressed: () {
              Navigator.pop(context);
              goTo(Schedule(initialCourseId: course.id));
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFC),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1564BF),
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String sectionName;
  final String taName;
  final String time;
  final String seats;
  final bool isFull;

  const SectionCard({
    super.key,
    required this.sectionName,
    required this.taName,
    required this.time,
    required this.seats,
    this.isFull = false,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = isFull ? const Color(0xFFD32F2F) : const Color(0xFF1564BF);
    final bgColor = isFull ? Colors.white : const Color(0xFFE8F1FB);
    final borderColor = isFull ? Colors.grey.shade300 : Colors.transparent;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: mainColor, width: 4.w)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFull ? Icons.cancel_outlined : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        seats,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(radius: 10.r, backgroundColor: Colors.grey.shade400),
                SizedBox(width: 8.w),
                Text(
                  taName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: Colors.blue.shade300),
                SizedBox(width: 6.w),
                Text(
                  time,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
