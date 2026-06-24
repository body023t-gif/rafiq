import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/course_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/course_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/course_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/course_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/courseexpandedsheet.dart';
import 'package:rafiq/features/course%20mangement/repository/course_repository.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  late final CourseCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final apiService = createApiService();
    _cubit = CourseCubit(
      CourseRepository(CourseRemoteDataSource(apiService)),
    )..loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إدارة المقررات'),
      body: BlocProvider.value(
        value: _cubit,
        child: BlocConsumer<CourseCubit, CourseState>(
          listener: (context, state) {
            if (state is CourseError && state.previousCourses != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is CourseLoading || state is CourseInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            final courses = switch (state) {
              CourseLoaded(:final filteredCourses) => filteredCourses,
              CourseActionLoading(:final courses) => courses,
              CourseActionSuccess(:final courses) => courses,
              CourseError(:final previousCourses) => previousCourses ?? const [],
              _ => const <CourseItemModel>[],
            };

            return RefreshIndicator(
              onRefresh: () => _cubit.loadCourses(refresh: true),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _searchController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'بحث عن مقرر...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      onChanged: _cubit.search,
                    ),
                    SizedBox(height: 12.h),
                    if (state is CourseActionLoading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: LinearProgressIndicator(minHeight: 2.h),
                      ),
                    Expanded(
                      child: courses.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 120.h),
                                Center(
                                  child: Text(
                                    state is CourseError
                                        ? state.message
                                        : 'لا توجد مقررات',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (state is CourseError) ...[
                                  SizedBox(height: 12.h),
                                  Center(
                                    child: FilledButton(
                                      onPressed: () => _cubit.loadCourses(),
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: courses.length + (state is CourseLoaded && state.hasMore ? 1 : 0),
                              separatorBuilder: (_, __) => SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                if (state is CourseLoaded &&
                                    state.hasMore &&
                                    index == courses.length) {
                                  return Center(
                                    child: TextButton(
                                      onPressed: () => _cubit.loadMore(),
                                      child: const Text('تحميل المزيد'),
                                    ),
                                  );
                                }
                                return _CourseCard(course: courses[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseItemModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xffE3E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.courseCode,
                style: TextStyle(
                  color: const Color(0xFF1564BF),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (course.isRecommended)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F2E6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: const Color(0xFF13773D), size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'موصى به',
                        style: TextStyle(
                          color: const Color(0xFF13773D),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            course.courseTitle,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          if (course.requirementType.isNotEmpty)
            _TagChip(text: course.requirementType),
          if (course.prerequisite.isNotEmpty) ...[
            SizedBox(height: 6.h),
            _TagChip(text: 'متطلب سابق: ${course.prerequisite}'),
          ],
          SizedBox(height: 14.h),
          const Divider(color: Color(0xffE3E4E8), height: 1),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: const Color(0xffACADB9), radius: 12.r),
                  SizedBox(width: 8.w),
                  Text(
                    course.instructorName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff5D5F6F),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.menu_book_outlined, color: const Color(0xff5D5F6F), size: 20.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '${course.creditHours} ساعات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff5D5F6F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: const Color(0xff5D5F6F), size: 20.sp),
                  SizedBox(width: 6.w),
                  Text(
                    course.scheduleTime.isEmpty ? '—' : course.scheduleTime,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff5D5F6F),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.people_outline, color: const Color(0xff5D5F6F), size: 20.sp),
                  SizedBox(width: 6.w),
                  Text(
                    course.seatsLabel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF13773D),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomFilledButton(
            icon: Icons.add,
            text: 'اضف إلى الجدول',
            width: double.infinity,
            height: 40.h,
            radius: 14.r,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CourseExpandedSheet(course: course),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD1E4FA),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xff17181C),
        ),
      ),
    );
  }
}
