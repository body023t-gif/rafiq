import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_cubit.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_state.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';
import 'package:rafiq/features/academic_calendar/repository/reminder_repository.dart';

class AddAppointmentScreen extends StatefulWidget {
  final DateTime? initialDate;
  const AddAppointmentScreen({super.key, this.initialDate});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  late final ReminderCubit _reminderCubit;
  bool _isLocalCubit = false;
  
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  
  bool _isTimePeriodEnabled = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _startDate = widget.initialDate!;
      _endDate = widget.initialDate!.add(const Duration(days: 7));
    }
    try {
      _reminderCubit = context.read<ReminderCubit>();
      _isLocalCubit = false;
    } catch (_) {
      final apiService = createApiService();
      _reminderCubit = ReminderCubit(
        ReminderRepository(ReminderRemoteDataSource(apiService)),
      );
      _isLocalCubit = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    if (_isLocalCubit) {
      _reminderCubit.close();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveAppointment() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان الموعد')),
      );
      return;
    }

    _reminderCubit.addReminder(
      _titleController.text.trim(),
      _detailsController.text.trim(),
      _startDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reminderCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "اضافه موعد"),
        body: SafeArea(
          child: BlocConsumer<ReminderCubit, ReminderState>(
            listener: (context, state) {
              if (state is ReminderActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              } else if (state is ReminderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ReminderLoading;

              return isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Directionality(
                      textDirection: TextDirection.rtl,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20.h),
                                    
                                    // Title Field
                                    Text(
                                      "عنوان الموعد",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    TextField(
                                      controller: _titleController,
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        hintText: "مثال: محاضرة أمن سيبراني",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                                        fillColor: const Color(0xFFF8F9FB),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                      ),
                                    ),
                                    
                                    SizedBox(height: 20.h),
                                    
                                    // Details Field
                                    Text(
                                      "التفاصيل",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    TextField(
                                      controller: _detailsController,
                                      textAlign: TextAlign.right,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: "أضف أي تفاصيل أو ملاحظات خاصة بالموعد...",
                                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                                        fillColor: const Color(0xFFF8F9FB),
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                      ),
                                    ),
                                    
                                    SizedBox(height: 24.h),
                                    
                                    // Time Period Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F5FF),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      padding: EdgeInsets.all(16.w),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_month, color: const Color(0xFF1E6FD9), size: 20.sp),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    "الفترة الزمنية",
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF1E293B),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Switch(
                                                value: _isTimePeriodEnabled,
                                                activeThumbColor: const Color(0xFF1E6FD9),
                                                onChanged: (val) {
                                                  setState(() {
                                                    _isTimePeriodEnabled = val;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          if (_isTimePeriodEnabled) ...[
                                            SizedBox(height: 12.h),
                                            const Divider(color: Color(0xFFD1E4FA)),
                                            // Start Date Selector
                                            InkWell(
                                              onTap: () => _selectDate(context, true),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "تبدأ من",
                                                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${_startDate.year}/${_startDate.month}/${_startDate.day}",
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: const Color(0xFF1E6FD9),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Icon(Icons.chevron_right, color: Colors.grey, size: 18.sp),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(color: Color(0xFFD1E4FA)),
                                            // End Date Selector
                                            InkWell(
                                            onTap: () => _selectDate(context, false),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "تنتهي في",
                                                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${_endDate.year}/${_endDate.month}/${_endDate.day}",
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color: const Color(0xFF1E6FD9),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Icon(Icons.chevron_right, color: Colors.grey, size: 18.sp),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: 16.h),
                                    
                                    // Notifications Toggle Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F5FF),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.notifications_active_outlined, color: const Color(0xFF1E6FD9), size: 20.sp),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "الإشعارات",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1E293B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Switch(
                                            value: _isNotificationEnabled,
                                            activeThumbColor: const Color(0xFF1E6FD9),
                                            onChanged: (val) {
                                              setState(() {
                                                _isNotificationEnabled = val;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Save button
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: CustomFilledButton(
                                text: "حفظ التغييرات",
                                backgroundColor: const Color(0xFF1E6FD9),
                                onPressed: _saveAppointment,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
