import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_cubit.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_state.dart';
import 'package:rafiq/features/academic_calendar/presentation/screens/add_appointment_screen.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_cubit.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';
import 'package:rafiq/features/academic_calendar/repository/reminder_repository.dart';

class DailyAlertsScreen extends StatefulWidget {
  final DateTime initialDate;
  const DailyAlertsScreen({super.key, required this.initialDate});

  @override
  State<DailyAlertsScreen> createState() => _DailyAlertsScreenState();
}

class _DailyAlertsScreenState extends State<DailyAlertsScreen> {
  late final ScheduleCubit _scheduleCubit;
  late final ReminderCubit _reminderCubit;
  bool _isLocalCubit = false;
  
  late DateTime _selectedDate;
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _generateWeekDays(_selectedDate);
    
    final apiService = createApiService();
    _scheduleCubit = ScheduleCubit(
      ScheduleRepository(ScheduleRemoteDataSource(apiService)),
    )..loadSchedule();
    
    try {
      _reminderCubit = context.read<ReminderCubit>();
      _isLocalCubit = false;
    } catch (_) {
      _reminderCubit = ReminderCubit(
        ReminderRepository(ReminderRemoteDataSource(apiService)),
      );
      _isLocalCubit = true;
    }
    
    if (_isLocalCubit || _reminderCubit.state is ReminderInitial || _reminderCubit.state is ReminderError) {
      _reminderCubit.loadReminders();
    }
  }

  @override
  void dispose() {
    _scheduleCubit.close();
    if (_isLocalCubit) {
      _reminderCubit.close();
    }
    super.dispose();
  }

  void _generateWeekDays(DateTime centerDate) {
    _weekDays = List.generate(7, (index) {
      return centerDate.add(Duration(days: index - 3));
    });
  }

  String _getArabicDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return "الاثنين";
      case DateTime.tuesday: return "الثلاثاء";
      case DateTime.wednesday: return "الأربعاء";
      case DateTime.thursday: return "الخميس";
      case DateTime.friday: return "الجمعة";
      case DateTime.saturday: return "السبت";
      case DateTime.sunday: return "الأحد";
      default: return "";
    }
  }

  String _getEnglishDayAbbr(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday: return "Mon";
      case DateTime.tuesday: return "Tue";
      case DateTime.wednesday: return "Wed";
      case DateTime.thursday: return "Thu";
      case DateTime.friday: return "Fri";
      case DateTime.saturday: return "Sat";
      case DateTime.sunday: return "Sun";
      default: return "";
    }
  }

  // Filter reminders for the selected day
  List<Map<String, dynamic>> _filteredRemindersForSelectedDay(List<Map<String, dynamic>> reminders) {
    return reminders.where((r) {
      try {
        final date = DateTime.parse(r['dueDate']);
        return date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final arabicDayName = _getArabicDayName(_selectedDate);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _reminderCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "تنبيهات أكاديمية"),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF1E6FD9),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: _reminderCubit,
                    child: AddAppointmentScreen(initialDate: _selectedDate),
                  ),
                ),
              );
              if (result == true) {
                _reminderCubit.loadReminders();
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocBuilder<ReminderCubit, ReminderState>(
              builder: (context, reminderState) {
                final reminders = reminderState is ReminderLoaded ? reminderState.reminders : const <Map<String, dynamic>>[];
                final isLoadingReminders = reminderState is ReminderLoading;

                return Column(
                  children: [
                    SizedBox(height: 12.h),
                    
                    // Horizontal Date Scroller
                    SizedBox(
                      height: 76.h,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: _weekDays.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          final date = _weekDays[index];
                          final isSelected = date.year == _selectedDate.year &&
                              date.month == _selectedDate.month &&
                              date.day == _selectedDate.day;
                          
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                            child: Container(
                              width: 56.w,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getEnglishDayAbbr(date),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white.withValues(alpha:0.8) : Colors.grey.shade400,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "${date.day}",
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Lecture Cards Scroller
                    BlocBuilder<ScheduleCubit, ScheduleState>(
                      builder: (context, state) {
                        List<ScheduleEntryModel> dayLectures = [];
                        if (state is ScheduleLoaded) {
                          dayLectures = state.schedule.entries.where((e) {
                            return e.day.trim() == arabicDayName;
                          }).toList();
                        }
                        
                        if (dayLectures.isEmpty) {
                          return SizedBox(
                            height: 100.h,
                            child: Center(
                              child: Text(
                                "لا توجد محاضرات في هذا اليوم",
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                              ),
                            ),
                          );
                        }
                        
                        return SizedBox(
                          height: 110.h,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: dayLectures.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final lecture = dayLectures[index];
                              
                              return Container(
                                width: 136.w,
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F5FF),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: const Color(0xFFD1E4FA)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.bookmark_outline,
                                          size: 14.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1E6FD9),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            lecture.sectionName.isNotEmpty ? lecture.sectionName : "محاضرة",
                                            style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lecture.startTime.isNotEmpty ? lecture.startTime : "11:30",
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 10.sp),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          lecture.courseTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: const Color(0xFF1E293B),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 20.h),
                    
                    // Tasks Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "المهام",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "الموعد/المهمة",
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Timeline List
                    Expanded(
                      child: isLoadingReminders
                          ? const Center(child: CircularProgressIndicator())
                          : Builder(
                              builder: (context) {
                                final dayTasks = _filteredRemindersForSelectedDay(reminders);
                                if (dayTasks.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "لا توجد مهام مسجلة لهذا اليوم",
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                                    ),
                                  );
                                }
                                
                                return Stack(
                                  children: [
                                    // Timeline dashed line
                                    Positioned(
                                      right: 42.w,
                                      top: 10.h,
                                      bottom: 10.h,
                                      child: Container(
                                        width: 1.5.w,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    ListView.builder(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      itemCount: dayTasks.length,
                                      itemBuilder: (context, index) {
                                        final task = dayTasks[index];
                                        final isCompleted = task['isCompleted'] ?? false;
                                        String timeLabel = "8:30";
                                        
                                        try {
                                          final t = DateTime.parse(task['dueDate']);
                                          final minStr = t.minute < 10 ? "0${t.minute}" : "${t.minute}";
                                          final hour = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
                                          final period = t.hour >= 12 ? "مساءً" : "صباحاً";
                                          timeLabel = "$hour:$minStr $period";
                                        } catch (_) {}

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 16.h),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60.w,
                                                height: 32.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(16.r),
                                                  border: Border.all(color: Colors.grey.shade200),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  timeLabel.split(" ").first,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              
                                              SizedBox(width: 8.w),
                                              CircleAvatar(
                                                radius: 5.r,
                                                backgroundColor: const Color(0xFF1E6FD9),
                                              ),
                                              SizedBox(width: 12.w),
                                              
                                              // The Card
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(12.w),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16.r),
                                                    border: Border.all(
                                                      color: isCompleted ? Colors.grey.shade200 : const Color(0xFF1E6FD9),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withValues(alpha:0.02),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      )
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        value: isCompleted,
                                                        activeColor: const Color(0xFF1E6FD9),
                                                        onChanged: (val) {
                                                          _reminderCubit.toggleReminder(task['id'], isCompleted);
                                                        },
                                                      ),
                                                      SizedBox(width: 6.w),
                                                      
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              task['title'] ?? "",
                                                              style: TextStyle(
                                                                fontSize: 13.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: isCompleted ? Colors.grey : const Color(0xFF1E293B),
                                                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                              ),
                                                            ),
                                                            if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                                                              SizedBox(height: 2.h),
                                                              Text(
                                                                task['description'],
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  fontSize: 10.sp,
                                                                  color: Colors.grey.shade500,
                                                                ),
                                                              ),
                                                            ]
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18.sp),
                                                        onPressed: () => _reminderCubit.deleteReminder(task['id']),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
