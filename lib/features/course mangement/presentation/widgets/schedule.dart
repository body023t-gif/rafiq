import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_state.dart';
import 'package:rafiq/features/course%20mangement/presentation/widgets/regenerateschedule.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';
import 'package:rafiq/features/course%20mangement/repository/timetable_repository.dart';

class Schedule extends StatefulWidget {
  final String? initialCourseId;

  const Schedule({super.key, this.initialCourseId});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late final ScheduleCubit _scheduleCubit;
  late final TimetableCubit _timetableCubit;

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
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    _timetableCubit.close();
    super.dispose();
  }

  StudentScheduleModel? _resolveSchedule(ScheduleState scheduleState, TimetableState timetableState) {
    final generated = timetableAsSchedule(timetableState);
    if (generated != null) return generated;
    if (scheduleState is ScheduleLoaded) return scheduleState.schedule;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _timetableCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TimetableCubit, TimetableState>(
            listener: (context, state) {
              if (state is TimetableSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _scheduleCubit.loadSchedule();
              } else if (state is TimetableError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, scheduleState) {
            return BlocBuilder<TimetableCubit, TimetableState>(
              builder: (context, timetableState) {
                final isLoading = scheduleState is ScheduleLoading ||
                    timetableState is TimetableGenerating ||
                    timetableState is TimetableSaving;

                if (isLoading &&
                    scheduleState is! ScheduleLoaded &&
                    timetableAsSchedule(timetableState) == null) {
                  return Scaffold(
                    appBar: const CustomAppBar(title: 'الجدول الدراسي'),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (scheduleState is ScheduleError && timetableAsSchedule(timetableState) == null) {
                  return Scaffold(
                    appBar: const CustomAppBar(title: 'الجدول الدراسي'),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(scheduleState.message, textAlign: TextAlign.center),
                          SizedBox(height: 12.h),
                          FilledButton(
                            onPressed: () => _scheduleCubit.retry(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final schedule = _resolveSchedule(scheduleState, timetableState);
                final totalHours = schedule?.totalHours ?? 0;
                final coursesCount = schedule?.registeredCoursesCount ?? 0;
                final entries = schedule?.entries ?? const [];

                return Scaffold(
                  appBar: const CustomAppBar(title: 'الجدول الدراسي'),
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.school_outlined,
                                label: 'إجمالي الساعات',
                                value: '$totalHours ساعة',
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.menu_book_outlined,
                                label: 'المقررات المسجلة',
                                value: '$coursesCount مقررات',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isLoading ? null : () => _scheduleCubit.loadSchedule(),
                                icon: Icon(Icons.edit_outlined, size: 18.sp, color: Colors.white),
                                label: Text('تعديل', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1564BF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading || schedule == null || entries.isEmpty
                                    ? null
                                    : () => _timetableCubit.save(schedule: schedule),
                                icon: Icon(Icons.save_outlined, size: 18.sp, color: const Color(0xFF1564BF)),
                                label: Text('حفظ', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1564BF))),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1564BF),
                                  side: const BorderSide(color: Color(0xFF1564BF)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (sheetContext) => BlocProvider.value(
                                            value: _timetableCubit,
                                            child: RegenerateScheduleSheet(
                                              courseIds: widget.initialCourseId == null
                                                  ? const []
                                                  : [widget.initialCourseId!],
                                            ),
                                          ),
                                        );
                                      },
                                icon: Icon(Icons.auto_awesome_outlined, size: 18.sp, color: Colors.white),
                                label: Text('إعادة توليد', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1564BF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        if (isLoading)
                          const LinearProgressIndicator(),
                        Expanded(
                          child: entries.isEmpty
                              ? Center(
                                  child: Text(
                                    scheduleState is ScheduleEmpty
                                        ? 'لا يوجد جدول مسجل حالياً'
                                        : 'لا توجد عناصر في الجدول',
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: entries.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    return _ScheduleEntryCard(entry: entry);
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

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffE3E4E8)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FB),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: const Color(0xFF1564BF), size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xff5D5F6F))),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleEntryCard extends StatelessWidget {
  final ScheduleEntryModel entry;

  const _ScheduleEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffE3E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.courseCode,
            style: TextStyle(
              color: const Color(0xFF1564BF),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            entry.courseTitle,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            entry.scheduleLabel,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xff5D5F6F)),
          ),
          if (entry.sectionName.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              entry.sectionName,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xff5D5F6F)),
            ),
          ],
        ],
      ),
    );
  }
}
