import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_cubit.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_state.dart';
import 'package:rafiq/features/academic_calendar/presentation/screens/add_appointment_screen.dart';

import 'package:rafiq/core/ui/global_state_widgets.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';
import 'package:rafiq/features/academic_calendar/repository/reminder_repository.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/event_remote_datasource.dart';
import 'package:rafiq/features/academic_calendar/repository/event_repository.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/event_cubit.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/event_state.dart';
import 'package:rafiq/features/academic_calendar/models/academic_event_model.dart';
class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  late final ReminderCubit _reminderCubit;
  late final EventCubit _eventCubit;
  bool _isLocalReminderCubit = false;
  bool _isLocalEventCubit = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _monthsArabic = [
    "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
    "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
  ];



  @override
  void initState() {
    super.initState();
    
    // Initialize ReminderCubit
    try {
      _reminderCubit = context.read<ReminderCubit>();
    } catch (_) {
      final apiService = createApiService();
      _reminderCubit = ReminderCubit(
        ReminderRepository(ReminderRemoteDataSource(apiService)),
      );
      _isLocalReminderCubit = true;
    }
    
    // Initialize EventCubit
    try {
      _eventCubit = context.read<EventCubit>();
    } catch (_) {
      final apiService = createApiService();
      _eventCubit = EventCubit(
        EventRepository(EventRemoteDataSource(apiService)),
      );
      _isLocalEventCubit = true;
    }
    
    if (_isLocalReminderCubit || _reminderCubit.state is ReminderInitial || _reminderCubit.state is ReminderError) {
      _reminderCubit.loadReminders();
    }
    
    if (_isLocalEventCubit || _eventCubit.state is EventInitial || _eventCubit.state is EventError) {
      _eventCubit.loadEvents();
    }
  }

  @override
  void dispose() {
    if (_isLocalReminderCubit) {
      _reminderCubit.close();
    }
    if (_isLocalEventCubit) {
      _eventCubit.close();
    }
    super.dispose();
  }

  void _showCalendarActionModal(DateTime date, List<AcademicEventModel> dateEvents, List<Map<String, dynamic>> dateReminders) {
    final monthName = _monthsArabic[date.month - 1];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "${date.day} $monthName",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 16.h),
                if (dateEvents.isNotEmpty) ...[
                  Text(
                    "الفعاليات الأكاديمية",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E6FD9)),
                  ),
                  SizedBox(height: 8.h),
                  ...dateEvents.map((event) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  event.eventType.isNotEmpty ? event.eventType : 'أكاديمي',
                                  style: TextStyle(fontSize: 10.sp, color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  event.eventName,
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (event.startTime.isNotEmpty && event.endTime.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14.sp, color: Colors.grey.shade600),
                                SizedBox(width: 4.w),
                                Text(
                                  "${event.startTime} - ${event.endTime}",
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                          if (event.location.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey.shade600),
                                SizedBox(width: 4.w),
                                Text(
                                  event.location,
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                          if (event.description.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              event.description,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                ],
                if (dateReminders.isNotEmpty) ...[
                  Text(
                    "تنبيهاتي",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF166534)),
                  ),
                  SizedBox(height: 8.h),
                  ...dateReminders.map((r) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: const Color(0xFF166534), size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              r['title'] ?? 'تنبيه',
                              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF166534)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                ],
                if (dateEvents.isEmpty && dateReminders.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Text(
                        "لا توجد فعاليات أو تنبيهات في هذا اليوم",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],
                // Add Reminder Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6FD9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: _reminderCubit,
                            child: AddAppointmentScreen(initialDate: date),
                          ),
                        ),
                      );
                      if (result == true) {
                        _reminderCubit.loadReminders();
                      }
                    },
                    icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                    label: Text(
                      "إضافة تنبيه",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Filter reminders for the selected month to show dots on calendar
  bool _hasReminderOnDay(DateTime date, List<Map<String, dynamic>> reminders) {
    return reminders.any((r) {
      try {
        final d = DateTime.parse(r['dueDate']);
        return d.year == date.year && d.month == date.month && d.day == date.day;
      } catch (_) {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthArabic = _monthsArabic[_selectedDate.month - 1];
    
    // Grid generation logic
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final totalDays = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final offset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _reminderCubit),
        BlocProvider.value(value: _eventCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "تقويم أكاديمي"),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocBuilder<EventCubit, EventState>(
              builder: (context, eventState) {
                final groupedEvents = eventState is EventLoaded ? eventState.groupedEvents : <DateTime, List<AcademicEventModel>>{};
                
                return BlocBuilder<ReminderCubit, ReminderState>(
                  builder: (context, state) {
                    final reminders = state is ReminderLoaded ? state.reminders : const <Map<String, dynamic>>[];
                    final isLoading = state is ReminderLoading || eventState is EventLoading;

                return Column(
                  children: [
                    // Calendar Card Container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(color: const Color(0xFFF0F5FF)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Month Navigation Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left, color: const Color(0xFF1E6FD9), size: 24.sp),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                                  });
                                },
                              ),
                              Text(
                                "$currentMonthArabic ${_selectedDate.year}",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right, color: const Color(0xFF1E6FD9), size: 24.sp),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // Days Header (RTL order: Sun to Sat)
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 7,
                            childAspectRatio: 1.5,
                            children: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map((day) {
                              return Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: const Color(0xFF1E6FD9),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 8.h),
                          
                          // Days Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 1.1,
                            ),
                            itemCount: 35,
                            itemBuilder: (context, index) {
                              final dayNumber = index - offset + 1;
                              if (dayNumber < 1 || dayNumber > totalDays) {
                                return const SizedBox();
                              }
                              
                              final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                              final isToday = date.day == DateTime.now().day &&
                                  date.month == DateTime.now().month &&
                                  date.year == DateTime.now().year;
                              
                              final hasReminder = _hasReminderOnDay(date, reminders);
                              final dateEvents = groupedEvents[date] ?? [];
                              final hasAcademicEvent = dateEvents.isNotEmpty;
                              
                              final dateReminders = reminders.where((r) {
                                try {
                                  final d = DateTime.parse(r['dueDate']);
                                  return d.year == date.year && d.month == date.month && d.day == date.day;
                                } catch (_) {
                                  return false;
                                }
                              }).toList();
                              
                              return InkWell(
                                onTap: () => _showCalendarActionModal(date, dateEvents, dateReminders),
                                child: Center(
                                  child: Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: isToday ? const Color(0xFF1E6FD9) : Colors.transparent,
                                      shape: BoxShape.circle,
                                      boxShadow: isToday
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF1E6FD9).withValues(alpha:0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$dayNumber",
                                            style: TextStyle(
                                              color: isToday ? Colors.white : const Color(0xFF1E293B),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          if (hasAcademicEvent || hasReminder)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (hasAcademicEvent)
                                                  Container(
                                                    width: 4.w,
                                                    height: 4.w,
                                                    margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: isToday ? Colors.white : Colors.orange,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                if (hasReminder)
                                                  Container(
                                                    width: 4.w,
                                                    height: 4.w,
                                                    margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: isToday ? Colors.white : const Color(0xFF1E6FD9),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Tasks List Title & Inline Add Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "المهام",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E6FD9),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.add, color: Colors.white, size: 18.sp),
                            ),
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
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    
                    // Reminders List (Timeline)
                    Expanded(
                      child: isLoading
                          ? const LoadingWidget(message: 'جاري تحميل التذكيرات...')
                          : state is ReminderError
                              ? ErrorStateWidget(
                                  message: state.message,
                                  onRetry: () => _reminderCubit.loadReminders(),
                                )
                              : reminders.isEmpty
                                  ? const EmptyStateWidget(
                                      message: 'لا توجد تذكيرات مسجلة',
                                      icon: Icons.notifications_off_outlined,
                                    )
                                  : Stack(
                                  children: [
                                    // Timeline vertical path
                                    Positioned(
                                      right: 38.w, // Positioned on the right in RTL
                                      top: 12.h,
                                      bottom: 12.h,
                                      child: Container(
                                        width: 2.w,
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () => _reminderCubit.loadReminders(),
                                      child: ListView.builder(
                                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                                        itemCount: reminders.length,
                                        itemBuilder: (context, index) {
                                          final reminder = reminders[index];
                                          final isCompleted = reminder['isCompleted'] ?? false;
                                          
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 14.h),
                                            child: Row(
                                              children: [
                                                // Time Node (small dot + icon bubble)
                                                Container(
                                                  width: 36.w,
                                                  height: 36.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: Colors.grey.shade200),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(Icons.schedule, color: Colors.grey.shade400, size: 18.sp),
                                                ),
                                                SizedBox(width: 8.w),
                                                CircleAvatar(
                                                  radius: 4.r,
                                                  backgroundColor: const Color(0xFF1E6FD9),
                                                ),
                                                SizedBox(width: 12.w),
                                                
                                                // Task Card
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(16.w),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(16.r),
                                                      border: Border.all(
                                                        color: isCompleted ? Colors.grey.shade200 : const Color(0xFF1E6FD9),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                          value: isCompleted,
                                                          activeColor: const Color(0xFF1E6FD9),
                                                          onChanged: (val) {
                                                            _reminderCubit.toggleReminder(reminder['id'], isCompleted);
                                                          },
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                reminder['title'] ?? "",
                                                                style: TextStyle(
                                                                  fontSize: 14.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: isCompleted ? Colors.grey : const Color(0xFF1E293B),
                                                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                                                ),
                                                              ),
                                                              if (reminder['description'] != null && reminder['description'].toString().isNotEmpty) ...[
                                                                SizedBox(height: 2.h),
                                                                Text(
                                                                  reminder['description'],
                                                                  style: TextStyle(
                                                                    fontSize: 11.sp,
                                                                    color: Colors.grey.shade500,
                                                                  ),
                                                                ),
                                                              ]
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20.sp),
                                                          onPressed: () => _reminderCubit.deleteReminder(reminder['id']),
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
                                    ),
                                  ],
                                ),
                    ),
                  ],
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
}
