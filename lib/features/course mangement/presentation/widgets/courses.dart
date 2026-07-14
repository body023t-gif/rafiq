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
import 'package:rafiq/features/course%20mangement/presentation/widgets/regenerateschedule.dart';
import 'package:rafiq/features/course%20mangement/repository/course_repository.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';
import 'package:rafiq/features/course%20mangement/repository/timetable_repository.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/schedule.dart';
import 'package:rafiq/features/course%20mangement/models/saved_timetable_model.dart';

void _showSavedTimetablesSheet(List<SavedTimetableModel> timetables, BuildContext context, TimetableCubit timetableCubit) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.all(20.w),
          constraints: BoxConstraints(maxHeight: 500.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "الجداول المحفوظة",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: timetables.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final t = timetables[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        timetableCubit.selectSavedTimetable(t);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Schedule()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.timetableName.isNotEmpty ? t.timetableName : "جدول #${index + 1}",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 8.h,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey.shade600),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "${t.totalDays} أيام",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.settings_suggest, size: 14.sp, color: Colors.grey.shade600),
                                    SizedBox(width: 4.w),
                                    Text(
                                      t.optionName,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  SnackBar(
                    content: Text(
                      state.message,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _courseCubit.loadCourses(refresh: true);
                _scheduleCubit.loadSchedule();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Schedule()),
                );
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
          BlocListener<TimetableCubit, TimetableState>(
            listener: (context, state) {
              if (state is TimetableGenerated || state is TimetableSaved) {
                _timetableCubit.loadSavedTimetables();
              } else if (state is SavedTimetableListLoaded) {
                _showSavedTimetablesSheet(state.timetables, context, _timetableCubit);
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
                        entry.status.isNotEmpty ? entry.status : "مسجل",
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
                if (entry.day.isNotEmpty || entry.startTime.isNotEmpty)
                  Text(
                    [entry.day, entry.startTime].where((e) => e.isNotEmpty).join(' • '),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                  ),
                if (entry.location.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  const Divider(color: Color(0xFFF1F5F9)),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        entry.location,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ]
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
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46.h,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E6FD9),
                              side: const BorderSide(color: Color(0xFF1E6FD9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const Schedule()),
                              );
                            },
                            icon: Icon(Icons.schedule, size: 16.sp),
                            label: Text(
                              "الجدول الحالي",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 46.h,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E6FD9),
                              side: const BorderSide(color: Color(0xFF1E6FD9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            onPressed: () => _timetableCubit.loadSavedTimetables(),
                            icon: Icon(Icons.bookmark_border, size: 16.sp),
                            label: Text(
                              "الجداول المحفوظة",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        _CourseSeatsLabel(course: course, courseCubit: _courseCubit),
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
                        : () async {
                            List<LectureGroupModel> lgList = course.lectureGroups;
                            List<CourseSectionModel> secList = course.sections;
                            
                            if (lgList.isEmpty || secList.isEmpty) {
                              final fullCourse = await _courseCubit.getCourseById(course.id);
                              if (fullCourse != null) {
                                lgList = fullCourse.lectureGroups;
                                secList = fullCourse.sections;
                              }
                            }

                            debugPrint('DEBUG: course.lectureGroups.length before open: ${lgList.length}');

                            if (!context.mounted) return;

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (sheetContext) => LectureGroupSelectionSheet(
                                course: course,
                                groups: lgList,
                                onSelect: (selectedGroup) {
                                  if (!context.mounted) return;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (secSheetContext) => SectionSelectionSheet(
                                      course: course,
                                      sections: secList,
                                      onSelect: (selectedSection) {
                                        _courseCubit.enrollCourse(
                                          course.id,
                                          selectedGroup.id,
                                          selectedSection.sectionId,
                                        );
                                      },
                                    ),
                                  ).then((_) => _scheduleCubit.loadSchedule());
                                },
                              ),
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

class LectureGroupSelectionSheet extends StatelessWidget {
  final CourseItemModel course;
  final List<LectureGroupModel> groups;
  final void Function(LectureGroupModel selected) onSelect;

  const LectureGroupSelectionSheet({
    super.key,
    required this.course,
    required this.groups,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
            "اختر مجموعة المحاضرة",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          if (groups.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Center(
                child: Text(
                  "لا توجد مجموعات محاضرات متاحة.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ...groups.map((group) {
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                onSelect(group);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "د. ${group.doctorName}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          group.seatsLabel,
                          style: TextStyle(
                            color: group.isFull ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          group.location,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "${group.day} - ${group.time}",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class SectionSelectionSheet extends StatelessWidget {
  final CourseItemModel course;
  final List<CourseSectionModel> sections;
  final void Function(CourseSectionModel selected) onSelect;

  const SectionSelectionSheet({
    super.key,
    required this.course,
    required this.sections,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
            "اختر الشعبة",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          if (sections.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: Center(
                child: Text(
                  "لا توجد شعب متاحة.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            ...sections.map((section) {
            return InkWell(
              onTap: () {
                Navigator.pop(context);
                onSelect(section);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          section.sectionName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          section.seatsLabel,
                          style: TextStyle(
                            color: section.isFull ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    if (section.scheduleTime.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            section.scheduleTime,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CourseSeatsLabel extends StatefulWidget {
  final CourseItemModel course;
  final CourseCubit courseCubit;

  const _CourseSeatsLabel({required this.course, required this.courseCubit});

  @override
  State<_CourseSeatsLabel> createState() => _CourseSeatsLabelState();
}

class _CourseSeatsLabelState extends State<_CourseSeatsLabel> {
  String _seatsLabel = '';

  @override
  void initState() {
    super.initState();
    _seatsLabel = widget.course.seatsLabel;
    _calculateSeats();
  }

  Future<void> _calculateSeats() async {
    List<LectureGroupModel> groups = widget.course.lectureGroups;

    if (groups.isEmpty) {
      final fullCourse = await widget.courseCubit.getCourseById(
        widget.course.id,
      );
      if (fullCourse != null) {
        groups = fullCourse.lectureGroups;
      }
    }

    if (groups.isNotEmpty) {
      int totalCap = 0;
      int totalReg = 0;

      for (var lg in groups) {
        int cap = lg.capacity;
        int avail = lg.availableSeats;
        int reg = lg.enrolledStudentsCount;

        if (reg == 0 && cap > 0 && avail >= 0) {
          reg = cap - avail;
        }

        totalCap += cap;
        totalReg += reg;
      }

      final newLabel = "$totalReg / $totalCap";

      if (mounted) {
        setState(() {
          _seatsLabel = newLabel;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _seatsLabel,
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF166534),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
