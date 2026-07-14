import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/chat ai/presentation/cubit/ai_assistant_cubit.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_state.dart';
import 'package:rafiq/features/profile/models/profile_model.dart';
import 'dart:math';

class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});

  @override
  State<GpaScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaScreen> {
  int _selectedSemesterIndex = -1;

  @override
  void initState() {
    super.initState();
    // Ensure profile data is loaded
    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.state is ProfileInitial) {
      profileCubit.loadProfile();
    }
  }

  double _getGradePoints(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'A+': return 4.0;
      case 'A': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'C+': return 2.7;
      case 'C': return 2.4;
      case 'D+': return 2.0;
      case 'D': return 1.3;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }

  double _calculateSemesterGpa(AcademicHistoryModel semester) {
    if (semester.courses.isEmpty) return 0.0;
    double totalPoints = 0.0;
    int totalCredits = 0;
    for (final course in semester.courses) {
      final gradePoints = _getGradePoints(course.grade);
      totalPoints += gradePoints * course.creditHours;
      totalCredits += course.creditHours;
    }
    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8F9FA),
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsetsDirectional.only(end: 20),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              "حاسبة المعدل",
              style: TextStyle(
                color: Color(0xff212529),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ),
        ),
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(
            right: 12,
            top: 14,
            bottom: 14,
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(21, 100, 191, 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const IconTheme(
                data: IconThemeData(color: Colors.white, size: 16),
                child: BackButtonIcon(),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<ProfileCubit>().loadProfile(),
                        child: const Text("إعادة المحاولة", style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileLoaded) {
              final profile = state.profile;
              final history = profile.academicHistory;

              final remainingHours = max(0, (profile.totalHours ?? 0) - (profile.completedHours ?? 0));

              final currentGpaStr = profile.currentGpa?.toStringAsFixed(2) ?? "--";
              final cumulativeGpaStr = profile.cumulativeGpa?.toStringAsFixed(2) ?? "--";
              final completedHoursStr = profile.completedHours?.toString() ?? "--";

              double semesterGpa = 0.0;
              AcademicHistoryModel? selectedSemester;

              if (history.isNotEmpty) {
                if (_selectedSemesterIndex == -1 || _selectedSemesterIndex >= history.length) {
                  _selectedSemesterIndex = history.length - 1; // default to latest
                }
                selectedSemester = history[_selectedSemesterIndex];
                
                semesterGpa = selectedSemester.semesterGpa;
                if (semesterGpa <= 0.0) {
                  semesterGpa = _calculateSemesterGpa(selectedSemester);
                }
              } else {
                semesterGpa = profile.currentGpa ?? 0.0;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xffA3C9F5),
                            Color(0xff0F488A),
                          ],
                          center: Alignment(0.0, 0.0),
                          radius: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "المعدل الأكاديمي تفاصيل السجل الدراسي",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeaderBox(
                                "المعدل الحالي",
                                currentGpaStr,
                              ),
                              const SizedBox(width: 10),
                              _buildHeaderBox(
                                "المعدل التراكمي",
                                cumulativeGpaStr,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeaderBox(
                                "الساعات المكتملة",
                                completedHoursStr,
                              ),
                              const SizedBox(width: 10),
                              _buildHeaderBox(
                                "الساعات المتبقية",
                                remainingHours.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "تفاصيل الفصل الدراسي",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff212529),
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<ProfileCubit>().loadProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("تم تحديث البيانات")),
                            );
                          },
                          child: Container(
                            width: 101,
                            height: 29,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xff1564BF),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "تحديث البيانات",
                              style: TextStyle(
                                color: Color(0xff1564BF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    if (history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xff1564BF).withValues(alpha: 0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: null,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              items: const [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    "الفصل الدراسي",
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              ],
                              onChanged: null,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      if (history.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xff1564BF).withValues(alpha: 0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedSemesterIndex,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xff1564BF)),
                                items: List.generate(history.length, (index) {
                                  final semGpa = history[index].semesterGpa > 0.0 
                                      ? history[index].semesterGpa 
                                      : _calculateSemesterGpa(history[index]);
                                  return DropdownMenuItem<int>(
                                    value: index,
                                    child: Text(
                                      "${history[index].semesterName} (معدل الفصل: ${semGpa.toStringAsFixed(2)})",
                                      style: const TextStyle(
                                        fontFamily: 'IBMPlexSansArabic',
                                        fontSize: 14,
                                        color: Color(0xff212529),
                                      ),
                                    ),
                                  );
                                }),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedSemesterIndex = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      else if (selectedSemester != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            "${selectedSemester.semesterName} (معدل الفصل: ${semesterGpa.toStringAsFixed(2)})",
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F488A),
                            ),
                          ),
                        ),
                    ],
                        
                    if (history.isEmpty)
                      _buildCoursesEmptyState()
                    else if (selectedSemester != null)
                      _buildCoursesList(selectedSemester.courses),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: history.isEmpty ? Colors.grey : const Color(0xff1564BF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        onPressed: history.isEmpty
                            ? null
                            : () {
                                context.read<AiAssistantCubit>().saveGpa(semesterGpa);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("تم حفظ معدل الفصل بنجاح: ${semesterGpa.toStringAsFixed(2)}"),
                                    backgroundColor: const Color(0xff1564BF),
                                  ),
                                );
                              },
                        child: Text(
                          "حفظ معدل الفصل",
                          style: TextStyle(
                            color: history.isEmpty ? Colors.white24 : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildCoursesEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "لا توجد سجلات دراسية مكتملة حتى الآن.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: Color(0xff212529),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "سيتم عرض المواد والدرجات بعد اعتماد النتائج من شؤون الطلاب.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'IBMPlexSansArabic',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBox(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 142.5,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xff0F488A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList(List<CourseModel> courses) {
    if (courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "لا توجد مقررات في هذا الفصل.",
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];

        return Container(
          width: 343,
          height: 116,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(209, 228, 250, 1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xff1564BF),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCourseField(
                "اسم المقرر",
                course.courseTitle,
                120,
                Alignment.center,
              ),
              _buildCourseField(
                "الدرجة",
                course.score > 0 ? course.score.toStringAsFixed(0) : "—",
                70,
                Alignment.center,
              ),
              _buildCourseField(
                "التقدير",
                course.grade.isNotEmpty ? course.grade : "—",
                70,
                Alignment.center,
                isGrade: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseField(
    String label,
    String value,
    double width,
    Alignment align, {
    bool isGrade = false,
  }) {
    return SizedBox(
      height: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromRGBO(21, 100, 191, 1),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ),
          Container(
            width: width,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color.fromRGBO(21, 100, 191, 1),
                width: 1.2,
              ),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: isGrade
                    ? const Color.fromRGBO(
                        21,
                        100,
                        191,
                        1,
                      )
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
