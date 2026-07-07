import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/core/utils/text_encoding.dart';
import 'package:rafiq/features/student_services/data/datasource/student_services_remote_datasource.dart';
import 'package:rafiq/features/student_services/presentation/cubit/student_services_cubit.dart';
import 'package:rafiq/features/student_services/presentation/cubit/student_services_state.dart';
import 'package:rafiq/features/student_services/presentation/screens/booking_success_screen.dart';
import 'package:rafiq/features/student_services/repository/student_services_repository.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/student_services/models/student_service_category.dart';

class AcademicServiceBookingScreen extends StatefulWidget {
  final String? initialServiceTitle;
  const AcademicServiceBookingScreen({super.key, this.initialServiceTitle});

  @override
  State<AcademicServiceBookingScreen> createState() => _AcademicServiceBookingScreenState();
}

class _AcademicServiceBookingScreenState extends State<AcademicServiceBookingScreen> {
  late final StudentServicesCubit _bookingCubit;
  
  final _nameController = TextEditingController();
  final _deptController = TextEditingController();
  final _idController = TextEditingController();
  final _reasonController = TextEditingController();

  StudentServiceCategory _selectedCategory = StudentServiceCategory.appointment;
  String _selectedDocumentType = "طلب إثبات قيد";
  String _selectedAdvisor = "د. أحمد علي - مكتب 402";
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<StudentServiceCategory> _serviceCategories = StudentServiceCategory.values;
  final List<String> _documentTypes = ["طلب إثبات قيد", "طلب بيان درجات"];

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceTitle != null) {
      _selectedCategory = StudentServiceCategory.fromTitle(widget.initialServiceTitle!);
      if (widget.initialServiceTitle!.contains("إثبات قيد")) {
        _selectedDocumentType = "طلب إثبات قيد";
      } else if (widget.initialServiceTitle!.contains("بيان درجات")) {
        _selectedDocumentType = "طلب بيان درجات";
      }
    }

    final apiService = createApiService();
    _bookingCubit = StudentServicesCubit(
      StudentServicesRepository(StudentServicesRemoteDataSource(apiService)),
    )..loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deptController.dispose();
    _idController.dispose();
    _reasonController.dispose();
    _bookingCubit.close();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      if (!mounted) return;
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTimeSpan(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00";
  }

  void _submitBooking() {
    if (_bookingCubit.state is StudentServicesLoading) return;

    final reasonText = _reasonController.text.trim();
    if (reasonText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ÙŠØ±Ø¬Ù‰ Ø¥Ø¯Ø®Ø§Ù„ Ø³Ø¨Ø¨ Ø§Ù„Ù…ÙˆØ¹Ø¯ Ø£Ùˆ Ø§Ù„Ø·Ù„Ø¨ Ø¨Ø´ÙƒÙ„ ÙˆØ§Ø¶Ø­", textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final serviceTitle = _selectedCategory == StudentServiceCategory.document
        ? _selectedDocumentType
        : _selectedCategory.arabicTitle;

    log('[Booking] User pressed Book');
    log('[Booking] Selected Category: ${_selectedCategory.name}');
    log('[Booking] Selected Document Type: $_selectedDocumentType');
    log('[Booking] Selected Service Title: $serviceTitle');
    log('[Booking] Selected Date: $_selectedDate');
    log('[Booking] Selected Time: ${_formatTimeSpan(_selectedTime)}');
    log('[Booking] Reason/Notes: $reasonText');
    log('[Booking] ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}');
    log('[Booking] ApiService.dynamicUserId: ${ApiService.dynamicUserId}');

    final studentId = ApiService.dynamicStudentId ?? ApiService.dynamicUserId ?? ApiService.staticUserId;

    if (_selectedCategory == StudentServiceCategory.appointment) {
      log('[Booking] Calling Cubit.bookService...');
      _bookingCubit.bookService(
        serviceType: 1, // Only used for Academic Appointment
        appointmentDate: _selectedDate,
        time: _formatTimeSpan(_selectedTime),
        notes: reasonText,
      );
    } else if (_selectedCategory == StudentServiceCategory.inquiry) {
      log('[Booking] Calling Cubit.sendGuidanceRequest...');
      _bookingCubit.sendGuidanceRequest(
        studentId: studentId ?? "",
        title: serviceTitle,
        description: reasonText,
      );
    } else if (_selectedCategory == StudentServiceCategory.document) {
      log('[Booking] Calling Cubit.requestDocument...');
      _bookingCubit.requestDocument(
        studentId: studentId ?? "",
        documentType: _selectedDocumentType,
        remarks: reasonText,
        topic: serviceTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: "حجز خدمة أكاديمية"),
        body: SafeArea(
          child: BlocListener<StudentServicesCubit, StudentServicesState>(
            listener: (context, state) {
              if (state is StudentServicesBookingSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingSuccessScreen(),
                  ),
                );
              } else if (state is StudentServicesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(repairUtf8Text(state.message), textDirection: TextDirection.rtl),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<StudentServicesCubit, StudentServicesState>(
              builder: (context, state) {
                final isInitialLoading = state is StudentServicesInitialDataLoading;
                final isActionLoading = state is StudentServicesLoading;

                if (state is StudentServicesInitialDataLoaded) {
                  _nameController.text = state.initialData.studentName;
                  _deptController.text = state.initialData.departmentName;
                  _idController.text = state.initialData.universityCode;
                  _selectedAdvisor = "${state.initialData.advisorName} - ${state.initialData.advisorLocation}";
                } else if (state is StudentServicesInitialDataError) {
                  // Robust fallback values if backend offline
                  _nameController.text = "طالب مستخدم";
                  _deptController.text = "الذكاء الاصطناعي";
                  _idController.text = "AI-992810";
                }

                return Stack(
                  children: [
                    if (isInitialLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Directionality(
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
                                      SizedBox(height: 16.h),
                                      
                                      // Section Title
                                      Container(
                                        decoration: const BoxDecoration(
                                          border: Border(right: BorderSide(color: Color(0xFF1D63B5), width: 4)),
                                        ),
                                        padding: EdgeInsets.only(right: 8.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "بيانات الطالب",
                                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                            ),
                                            Text(
                                              "يرجى التحقق من معلوماتك قبل المتابعة.",
                                              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 16.h),

                                      // Name Field (Read Only)
                                      Text("الاسم الكامل", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                      SizedBox(height: 6.h),
                                      TextField(
                                        controller: _nameController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          fillColor: const Color(0xFFEFF6FF),
                                          filled: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                        ),
                                      ),
                                      SizedBox(height: 12.h),

                                      Row(
                                        children: [
                                          // Department Field
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("القسم", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                                SizedBox(height: 6.h),
                                                TextField(
                                                  controller: _deptController,
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    fillColor: const Color(0xFFEFF6FF),
                                                    filled: true,
                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          // ID Field
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("الرقم الجامعي", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                                SizedBox(height: 6.h),
                                                TextField(
                                                  controller: _idController,
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    fillColor: const Color(0xFFEFF6FF),
                                                    filled: true,
                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24.h),

                                      // Service Selection
                                      Text(
                                        "اختيار نوع الخدمة",
                                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                      ),
                                      SizedBox(height: 6.h),
                                      Text("ماذا تريد أن تفعل؟", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
                                      SizedBox(height: 8.h),
                                      DropdownButtonFormField<StudentServiceCategory>(
                                        value: _selectedCategory,
                                        items: _serviceCategories.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(type.arabicTitle),
                                            ),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          fillColor: const Color(0xFFEFF6FF),
                                          filled: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                        ),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedCategory = val;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: 12.h),

                                      // Document Sub-selection
                                      if (_selectedCategory == StudentServiceCategory.document) ...[
                                        Text("نوع الوثيقة المطلوبة", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                        SizedBox(height: 6.h),
                                        DropdownButtonFormField<String>(
                                          value: _selectedDocumentType,
                                          items: _documentTypes.map((type) {
                                            return DropdownMenuItem(
                                              value: type,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(type),
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            fillColor: const Color(0xFFEFF6FF),
                                            filled: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                          ),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedDocumentType = val;
                                              });
                                            }
                                          },
                                        ),
                                        SizedBox(height: 24.h),
                                      ],

                                      // Appointment details section
                                      if (_selectedCategory == StudentServiceCategory.appointment) ...[
                                        Text(
                                          "تفاصيل الموعد",
                                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text("المكتب / المرشد", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                        SizedBox(height: 6.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            _selectedAdvisor,
                                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            // Date selector
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("التاريخ", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: () => _selectDate(context),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(12.r),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}",
                                                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                                          ),
                                                          Icon(Icons.calendar_month_outlined, color: Colors.grey.shade500, size: 18.sp),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            // Time selector
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("الوقت", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                                                  SizedBox(height: 6.h),
                                                  InkWell(
                                                    onTap: () => _selectTime(context),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(12.r),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            _selectedTime.format(context),
                                                            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                                          ),
                                                          Icon(Icons.access_time, color: Colors.grey.shade500, size: 18.sp),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 24.h),
                                      ],

                                      // Reason Text Area
                                      Text(
                                        "سبب الموعد / الطلب",
                                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                                      ),
                                      SizedBox(height: 8.h),
                                      TextField(
                                        controller: _reasonController,
                                        maxLines: 4,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          hintText: "اكتب باختصار الموضوع الذي ترغب في مناقشته أو سبب طلب الوثيقة...",
                                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                                          fillColor: const Color(0xFFEFF6FF),
                                          filled: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                        ),
                                      ),
                                      SizedBox(height: 30.h),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Submit Button
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: CustomFilledButton(
                                  text: "تأكيد الطلب",
                                  backgroundColor: const Color(0xFF1D63B5),
                                  onPressed: _submitBooking,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isActionLoading)
                      Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(child: CircularProgressIndicator()),
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
