import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/course_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/course_model.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/course_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/course_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/courseexpandedsheet.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/regenerateschedule.dart';
import 'package:rafiq/features/course%20mangement/repository/course_repository.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';
import 'package:rafiq/features/course%20mangement/repository/timetable_repository.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  late final CourseCubit _courseCubit;
  late final ScheduleCubit _scheduleCubit;
  late final TimetableCubit _timetableCubit;
  final TextEditingController _searchController = TextEditingController();
  int _activeTab = 0; // 0 for "مقرراتي", 1 for "المقررات المتاحة"

  @override
  void initState() {
    super.initState();
    final apiService = createApiService();
    _courseCubit = CourseCubit(
      CourseRepository(CourseRemoteDataSource(apiService)),
    )..loadCourses();
    _scheduleCubit = ScheduleCubit(
      ScheduleRepository(ScheduleRemoteDataSource(apiService)),
    )..loadSchedule();
    _timetableCubit = TimetableCubit(
      TimetableRepository(TimetableRemoteDataSource(apiService)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _courseCubit.close();
    _scheduleCubit.close();
    _timetableCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _courseCubit),
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _timetableCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CourseCubit, CourseState>(
            listener: (context, state) {
              if (state is CourseActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم تنفيذ العملية بنجاح.", style: TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Colors.green,
                  ),
                );
                _scheduleCubit.loadSchedule();
              } else if (state is CourseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: const CustomAppBar(title: 'إدارة المقررات'),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, scheduleState) {
                return BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, courseState) {
                    return BlocBuilder<TimetableCubit, TimetableState>(
                      builder: (context, timetableState) {
                        final isLoading = scheduleState is ScheduleLoading ||
                            courseState is CourseLoading ||
                            courseState is CourseActionLoading ||
                            timetableState is TimetableSaving ||
                            timetableState is TimetableGenerating;
                  // Extract stats from schedule
                  int creditHoursVal = 0;
                  int registeredCountVal = 0;
                  if (scheduleState is ScheduleLoaded) {
                    creditHoursVal = scheduleState.schedule.totalHours;
                    registeredCountVal = scheduleState.schedule.registeredCoursesCount;
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        if (isLoading) const LinearProgressIndicator(),
                        SizedBox(height: 12.h),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard("المعدل المستهدف", "4.0", const Color(0xFF3B82F6)),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildStatCard("ساعات معتمدة", "$creditHoursVal", const Color(0xFF1E56A0)),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildStatCard("مسجل", "$registeredCountVal", const Color(0xFF4D96FF)),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Tab Bar
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _activeTab = 0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _activeTab == 0 ? const Color(0xFF2563EB) : Colors.transparent,
                                          width: 2.w,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "مقرراتي",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.normal,
                                        color: _activeTab == 0 ? const Color(0xFF2563EB) : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _activeTab = 1),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _activeTab == 1 ? const Color(0xFF2563EB) : Colors.transparent,
                                          width: 2.w,
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "المقررات المتاحة",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.normal,
                                        color: _activeTab == 1 ? const Color(0xFF2563EB) : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'بحث...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            fillColor: const Color(0xFFE2E8F0),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          ),
                          onChanged: (val) {
                            if (_activeTab == 1) {
                              _courseCubit.search(val);
                            }
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Content List
                        Expanded(
                          child: _activeTab == 0
                              ? _buildMyCoursesList(scheduleState)
                              : _buildAvailableCoursesList(
                                  courseState,
                                  scheduleState,
                                  isLoading: isLoading,
                                ),
                        ),
                      ],
                    ),
                  );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha:0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCoursesList(ScheduleState state) {
    if (state is ScheduleLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ScheduleEmpty || state is ScheduleInitial) {
      return Center(
        child: Text(
          "لم تقم بتسجيل أي مقررات بعد",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        ),
      );
    }
    if (state is ScheduleError) {
      return Center(child: Text(state.message));
    }

    final entries = (state as ScheduleLoaded).schedule.entries;
    
    // Apply search filter locally for my courses
    final query = _searchController.text.trim().toLowerCase();
    final filteredEntries = entries.where((e) {
      if (query.isEmpty) return true;
      return e.courseCode.toLowerCase().contains(query) ||
          e.courseTitle.toLowerCase().contains(query) ||
          e.instructorName.toLowerCase().contains(query);
    }).toList();

    // Prevent duplicate cards for courses that have multiple lecture/lab slots
    final uniqueEntriesMap = <String, ScheduleEntryModel>{};
    for (final entry in filteredEntries) {
      uniqueEntriesMap.putIfAbsent(entry.courseCode, () => entry);
    }
    final uniqueEntries = uniqueEntriesMap.values.toList();

    if (uniqueEntries.isEmpty) {
      return Center(
        child: Text(
          "لا توجد نتائج مطابقة لبحثك",
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _scheduleCubit.loadSchedule(),
      child: ListView.separated(
        itemCount: uniqueEntries.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final entry = uniqueEntries[index];
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        "مسجل",
                        style: TextStyle(
                          color: const Color(0xFF166534),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      entry.courseCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E56A0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  entry.courseTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "د. ${entry.instructorName} • ${entry.startTime.isNotEmpty ? entry.startTime : '—'}",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                ),
                SizedBox(height: 12.h),
                const Divider(color: Color(0xFFF1F5F9)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "${entry.creditHours} ساعات",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.class_outlined, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          entry.sectionName.isNotEmpty ? entry.sectionName : "شعبة 1",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailableCoursesList(
    CourseState state,
    ScheduleState scheduleState, {
    required bool isLoading,
  }) {
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
      onRefresh: () => _courseCubit.loadCourses(refresh: true),
      child: ListView.builder(
        itemCount: courses.length + 1, // +1 for the Generator CTA at the bottom
        itemBuilder: (context, index) {
          if (index == courses.length) {
            // Render Smart Generator CTA Card
            return Container(
              margin: EdgeInsets.symmetric(vertical: 16.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F5FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, color: const Color(0xFF2563EB), size: 28.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Smart Schedule Generator",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "إنشاء جدول مُحسن بدون أي تعارضات دراسية تلقائياً",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) => BlocProvider.value(
                            value: _timetableCubit,
                            child: RegenerateScheduleSheet(
                              courseIds: scheduleState is ScheduleLoaded
                                  ? scheduleState.schedule.entries
                                      .map((e) => e.courseId ?? '')
                                      .where((id) => id.isNotEmpty)
                                      .toList()
                                  : const [],
                            ),
                          ),
                        ).then((_) => _scheduleCubit.loadSchedule());
                      },
                      icon: Icon(Icons.flash_on, color: Colors.white, size: 16.sp),
                      label: Text(
                        "إنشاء جدول ذكي",
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final course = courses[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        course.requirementType.isNotEmpty ? course.requirementType : "اختياري",
                        style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      course.courseCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E56A0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  course.courseTitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "د. ${course.instructorName} • ${course.scheduleTime.isNotEmpty ? course.scheduleTime : '—'}",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "${course.creditHours} ساعات",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          course.seatsLabel,
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF166534), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey.shade300 : const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => CourseExpandedSheet(course: course),
                            ).then((_) => _scheduleCubit.loadSchedule());
                          },
                    child: Text(
                      "تسجيل",
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
