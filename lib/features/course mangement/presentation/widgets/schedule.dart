import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/core/utils/text_encoding.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/weekly_timetable_grid.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/course_remote_datasource.dart';
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
import 'package:rafiq/features/course%20mangement/models/saved_timetable_model.dart';

class Schedule extends StatefulWidget {
  final String? initialCourseId;

  const Schedule({super.key, this.initialCourseId});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late final ScheduleCubit _scheduleCubit;
  late final TimetableCubit _timetableCubit;
  late final CourseCubit _courseCubit;
  bool _isEditMode = false;
  final Set<String> _removedEntryIds = {};
  String _selectedDay = "الأحد";

  static const _saveBeforeGenerateMessage = 'لا يمكن حفظ جدول قبل توليده.';

  final List<String> _academicDays = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس"];

  @override
  void initState() {
    super.initState();
    final apiService = createApiService();
    _scheduleCubit = ScheduleCubit(
      ScheduleRepository(ScheduleRemoteDataSource(apiService)),
    )..loadSchedule();
    _timetableCubit = TimetableCubit(
      TimetableRepository(TimetableRemoteDataSource(apiService)),
    );
    _courseCubit = CourseCubit(
      CourseRepository(CourseRemoteDataSource(apiService)),
    );

    final today = DateTime.now();
    final dayName = _getArabicDayName(today);
    if (_academicDays.contains(dayName)) {
      _selectedDay = dayName;
    } else {
      _selectedDay = "الأحد";
    }
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    _timetableCubit.close();
    _courseCubit.close();
    super.dispose();
  }

  String _getArabicDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return "الاثنين";
      case DateTime.tuesday:
        return "الثلاثاء";
      case DateTime.wednesday:
        return "الأربعاء";
      case DateTime.thursday:
        return "الخميس";
      case DateTime.friday:
        return "الجمعة";
      case DateTime.saturday:
        return "السبت";
      case DateTime.sunday:
        return "الأحد";
      default:
        return "";
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          repairUtf8Text(message),
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  StudentScheduleModel? _resolveSchedule(ScheduleState scheduleState, TimetableState timetableState) {
    final generated = timetableAsSchedule(timetableState);
    if (generated != null) return generated;
    if (scheduleState is ScheduleLoaded) return scheduleState.schedule;
    return null;
  }

  List<ScheduleEntryModel> _filterDayEntries(List<ScheduleEntryModel> entries) {
    final seenGroupIds = <String>{};
    final dayEntries = <ScheduleEntryModel>[];

    for (final entry in entries) {
      if (_removedEntryIds.contains(entry.id)) continue;
      if (entry.day.trim() != _selectedDay) continue;

      final groupId = entry.lectureGroupId;
      if (groupId != null && groupId.isNotEmpty) {
        if (seenGroupIds.contains(groupId)) continue;
        seenGroupIds.add(groupId);
      }
      dayEntries.add(entry);
    }

    return dayEntries;
  }

  void _toggleEditMode() {
    final currentTimetableState = _timetableCubit.state;
    final currentScheduleState = _scheduleCubit.state;
    dev.log('[Edit Trace] Edit mode toggled. Enters edit mode?: ${!_isEditMode}');
    dev.log('  - Current Timetable Cubit State: $currentTimetableState');
    dev.log('  - Current Schedule Cubit State: $currentScheduleState');
    dev.log('  - Does it reload schedule?: false (kept in local state)');
    dev.log('  - Does it reset timetable?: false (kept in local state)');
    dev.log('  - Does it clear generated data?: false');

    setState(() {
      if (_isEditMode) {
        _isEditMode = false;
        _removedEntryIds.clear();
      } else {
        _isEditMode = true;
        _removedEntryIds.clear();
      }
    });

    dev.log('[Edit Trace] Edit mode state after toggle: _isEditMode = $_isEditMode, _removedEntryIdsCount = ${_removedEntryIds.length}');
  }

  void _removeEntryInEditMode(ScheduleEntryModel entry) {
    setState(() {
      if (entry.id.isNotEmpty) {
        _removedEntryIds.add(entry.id);
      }
    });
    _showSnackBar(
      context,
      'تمت إزالة "${entry.courseTitle}" من العرض',
      backgroundColor: const Color(0xFF1E6FD9),
    );
  }

  void _handleSave(TimetableState timetableState, StudentScheduleModel? schedule) {
    if (isTimetableBusy(timetableState)) return;

    if (canSaveTimetable(timetableState)) {
      _timetableCubit.save(schedule: schedule);
      return;
    }

    _showSnackBar(context, _saveBeforeGenerateMessage);
  }

  void _openGenerateSheet(List<ScheduleEntryModel> entries) {
    if (_isEditMode) {
      setState(() {
        _isEditMode = false;
        _removedEntryIds.clear();
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: _timetableCubit,
        child: RegenerateScheduleSheet(
          courseIds: widget.initialCourseId != null
              ? [widget.initialCourseId!]
              : entries.map((e) => e.courseId ?? '').where((id) => id.isNotEmpty).toList(),
        ),
      ),
    );
  }

  void _showSavedTimetablesSheet(List<SavedTimetableModel> timetables) {
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
                        // Select the saved timetable
                        _timetableCubit.selectSavedTimetable(t);
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
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey.shade600),
                                SizedBox(width: 4.w),
                                Text(
                                  "${t.totalDays} أيام",
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12.sp),
                                ),
                                SizedBox(width: 16.w),
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _timetableCubit),
        BlocProvider.value(value: _courseCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TimetableCubit, TimetableState>(
            listener: (context, state) {
              if (state is TimetableGenerated) {
                setState(() {
                  _isEditMode = false;
                  _removedEntryIds.clear();
                });
              } else if (state is TimetableSaved) {
                _showSnackBar(
                  context,
                  state.message,
                  backgroundColor: Colors.green,
                );
                _timetableCubit.resetAfterSave();
                _scheduleCubit.loadSchedule(silent: true);
              } else if (state is TimetableError) {
                _showSnackBar(context, state.message);
              } else if (state is SavedTimetableListLoaded) {
                _showSavedTimetablesSheet(state.timetables);
              }
            },
          ),
          BlocListener<CourseCubit, CourseState>(
            listener: (context, state) {
              if (state is CourseActionSuccess) {
                _showSnackBar(
                  context,
                  "تم تنفيذ العملية بنجاح.",
                  backgroundColor: Colors.green,
                );
                _scheduleCubit.loadSchedule(silent: true);
              } else if (state is CourseError) {
                _showSnackBar(context, state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, scheduleState) {
            return BlocBuilder<TimetableCubit, TimetableState>(
              builder: (context, timetableState) {
                final schedule = _resolveSchedule(scheduleState, timetableState);
                final entries = schedule?.entries ?? const [];
                final dayEntries = _filterDayEntries(entries);

                final isTimetableActionBusy = isTimetableBusy(timetableState);
                final canSave = canSaveTimetable(timetableState);
                final hasContent = schedule != null;
                final isInitialLoading = scheduleState is ScheduleLoading && !hasContent;
                final showProgressBar = isTimetableActionBusy ||
                    (scheduleState is ScheduleLoading && hasContent);

                if (isInitialLoading) {
                  return const Scaffold(
                    appBar: CustomAppBar(title: 'الجدول الدراسي'),
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (scheduleState is ScheduleError && !hasContent) {
                  return Scaffold(
                    appBar: const CustomAppBar(title: 'الجدول الدراسي'),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            repairUtf8Text(scheduleState.message),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => _scheduleCubit.retry(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: const CustomAppBar(title: 'الجدول الدراسي'),
                  body: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),

                        if (_isEditMode)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: const Color(0xFFFDBA74)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.edit_note, color: Colors.orange.shade700, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'وضع التعديل — اضغط على × لإزالة محاضرة من العرض',
                                    style: TextStyle(
                                      color: Colors.orange.shade900,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_isEditMode) SizedBox(height: 10.h),

                        SizedBox(
                          height: 48.h,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: _academicDays.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final day = _academicDays[index];
                              final isSelected = day == _selectedDay;

                              return InkWell(
                                onTap: () => setState(() => _selectedDay = day),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF1E6FD9) : Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : const Color(0xFFF1F6FF),
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF1E6FD9).withValues(alpha:0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : null,
                                  ),
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade500,
                                      fontSize: 14.sp,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 20.h),

                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.all(_isEditMode ? 10.w : 0),
                          decoration: _isEditMode
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
                                )
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isEditMode
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFF1E6FD9),
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    onPressed: isTimetableActionBusy ? null : _toggleEditMode,
                                    icon: Icon(
                                      _isEditMode ? Icons.check : Icons.edit_outlined,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _isEditMode ? "إنهاء" : "تعديل",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SizedBox(
                                  height: 44.h,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: canSave && !isTimetableActionBusy
                                          ? const Color(0xFF1E6FD9)
                                          : Colors.grey.shade500,
                                      side: BorderSide(
                                        color: canSave && !isTimetableActionBusy
                                            ? const Color(0xFF1E6FD9)
                                            : Colors.grey.shade300,
                                      ),
                                      disabledForegroundColor: Colors.grey.shade500,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    onPressed: isTimetableActionBusy
                                        ? null
                                        : () => _handleSave(timetableState, schedule),
                                    icon: Icon(
                                      Icons.save_outlined,
                                      size: 16.sp,
                                      color: canSave && !isTimetableActionBusy
                                          ? const Color(0xFF1E6FD9)
                                          : Colors.grey.shade500,
                                    ),
                                    label: Text(
                                      "حفظ",
                                      style: TextStyle(
                                        color: canSave && !isTimetableActionBusy
                                            ? const Color(0xFF1E6FD9)
                                            : Colors.grey.shade500,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    onPressed: isTimetableActionBusy
                                        ? null
                                        : () => _openGenerateSheet(entries),
                                    icon: Icon(Icons.auto_awesome_outlined, size: 16.sp, color: Colors.white),
                                    label: Text(
                                      "توليد",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          width: double.infinity,
                          height: 44.h,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E6FD9),
                              side: const BorderSide(color: Color(0xFF1E6FD9)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            onPressed: isTimetableActionBusy ? null : () => _timetableCubit.loadSavedTimetables(),
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


                        if (hasGeneratedTimetable(timetableState))
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(20.w, 10.h, 20.w, 0),
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                'جدول مُولَّد — يمكنك حفظه أو إعادة التوليد',
                                style: TextStyle(
                                  color: const Color(0xFF166534),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 12.h),

                        if (showProgressBar) const LinearProgressIndicator(),

                        Expanded(
                          child: hasGeneratedTimetable(timetableState)
                              ? WeeklyTimetableGrid(entries: entries)
                              : dayEntries.isEmpty
                                  ? Center(
                                      child: Text(
                                        "لا توجد محاضرات في هذا اليوم",
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                                  itemCount: dayEntries.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    final entry = dayEntries[index];
                                    final isLab = entry.sectionName.toLowerCase().contains("عملي") ||
                                        entry.sectionName.toLowerCase().contains("lab");

                                    return Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: _isEditMode ? const Color(0xFFFFFBEB) : Colors.white,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: _isEditMode
                                              ? const Color(0xFFFED7AA)
                                              : const Color(0xFFF1F5F9),
                                        ),
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
                                              Text(
                                                entry.timeLabel,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey.shade400,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 10.w,
                                                      vertical: 4.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isLab
                                                          ? const Color(0xFFF5F3FF)
                                                          : const Color(0xFFE0F2FE),
                                                      borderRadius: BorderRadius.circular(20.r),
                                                    ),
                                                    child: Text(
                                                      entry.sectionName.isNotEmpty
                                                          ? entry.sectionName
                                                          : "محاضرة",
                                                      style: TextStyle(
                                                        color: isLab
                                                            ? const Color(0xFF7C3AED)
                                                            : const Color(0xFF0369A1),
                                                        fontSize: 10.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (_isEditMode) ...[
                                                    SizedBox(width: 8.w),
                                                    InkWell(
                                                      onTap: () => _removeEntryInEditMode(entry),
                                                      child: Container(
                                                        padding: EdgeInsets.all(4.w),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFFEE2E2),
                                                          borderRadius: BorderRadius.circular(20.r),
                                                        ),
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 16.sp,
                                                          color: const Color(0xFFDC2626),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.h),
                                          Text(
                                            entry.courseTitle,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on_outlined,
                                                      color: Colors.grey, size: 16.sp),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    "قاعة الكلية",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 24.w),
                                              Row(
                                                children: [
                                                  Icon(Icons.person_outline,
                                                      color: Colors.grey, size: 16.sp),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    entry.instructorName,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.grey.shade600,
                                                    ),
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
