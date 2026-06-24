import'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/profile/models/profile_model.dart' as profile_models;
import 'package:rafiq/features/user_profile/presentation/widgets/academichistory/cubit/model.dart';
import 'package:rafiq/features/user_profile/presentation/widgets/academic_history_widget.dart';
import 'package:rafiq/features/user_profile/presentation/widgets/progresscards/cubit/model.dart';
import 'package:rafiq/features/user_profile/presentation/widgets/profile_progress_cards_widget.dart';


class UserProfileScreen extends StatelessWidget {
  final File? userImage;
  final profile_models.ProfileModel profile;
  const UserProfileScreen({
    super.key,
    this.userImage,
    required this.profile,
  });



  @override
  Widget build(BuildContext context) {
    return _buildContent(context, profile);
  }

  Widget _buildContent(BuildContext context, profile_models.ProfileModel loadedProfile) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundImage: userImage != null
                          ? FileImage(userImage!)
                          : const AssetImage(
                        'assets/images/default_avatar.png',
                      ) as ImageProvider,
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _splitName(loadedProfile.fullName).$1,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _splitName(loadedProfile.fullName).$2,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "رقم الطالب: ${loadedProfile.universityCode}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF9092A2),
                          ),
                        ),

                        SizedBox(height: 8.h),
                        Text(
                          "القسم: ${loadedProfile.departmentName}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF9092A2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),


                ProgressCards(
                  progress: StudentProgressModel.fromProfile(
                    currentGpa: loadedProfile.currentGpa,
                    level: loadedProfile.level,
                    completedHours: loadedProfile.completedHours,
                    totalHours: loadedProfile.totalHours,
                    advisorName: loadedProfile.academicAdvisorName,
                  ),
                ),
                SizedBox(height: 24.h),
                AcademicHistoryView(
                  semesters: _mapSemesters(loadedProfile),
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<SemesterModel> _mapSemesters(profile_models.ProfileModel profile) {
  if (profile.academicHistory.isEmpty) {
    return [
      SemesterModel(semesterName: 'لا يوجد بيانات', gpa: 0, courses: const []),
    ];
  }
  return profile.academicHistory
      .map(
        (semester) => SemesterModel(
          semesterName: semester.semesterName,
          gpa: semester.semesterGpa,
          courses: semester.courses
              .map(
                (course) => CourseModel(
                  code: course.courseCode,
                  name: course.courseTitle,
                  creditHours: course.creditHours,
                  grade: course.grade,
                  degree: course.score,
                ),
              )
              .toList(),
        ),
      )
      .toList();
}

(String, String) _splitName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) {
    return ('', '');
  }
  if (parts.length == 1) {
    return (parts.first, '');
  }
  return (parts.first, parts.sublist(1).join(' '));
}
