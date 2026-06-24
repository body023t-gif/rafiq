import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/study%20plan/data/datasource/study_plan_remote_datasource.dart';
import 'package:rafiq/features/study%20plan/models/study_plan_model.dart';
import 'package:rafiq/features/study%20plan/presentation/cubit/study_plan_cubit.dart';
import 'package:rafiq/features/study%20plan/presentation/cubit/study_plan_state.dart';
import 'package:rafiq/features/study%20plan/repository/study_plan_repository.dart';
import 'package:rafiq/core/ui/appbar.dart';

class StudyPlanView extends StatefulWidget {
  const StudyPlanView({super.key});

  @override
  State<StudyPlanView> createState() => _StudyPlanViewState();
}

class _StudyPlanViewState extends State<StudyPlanView> {
  late final StudyPlanCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = StudyPlanCubit(
      StudyPlanRepository(
        StudyPlanRemoteDataSource(createApiService()),
      ),
    )..loadStudyPlan(ApiService.staticUserId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تحسين خطة الدراسة'),
      body: BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<StudyPlanCubit, StudyPlanState>(
          builder: (context, state) {
            if (state is StudyPlanLoading || state is StudyPlanInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StudyPlanError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                    FilledButton(
                      onPressed: () => _cubit.retry(ApiService.staticUserId),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            if (state is StudyPlanEmpty) {
              return Center(
                child: Text(
                  'لا توجد خطة دراسية متاحة',
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            }

            final plan = (state as StudyPlanLoaded).plan;
            final items = _planItems(plan);

            return RefreshIndicator(
              onRefresh: () => _cubit.loadStudyPlan(ApiService.staticUserId),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                children: [
                  _SummaryRow(
                    completed: plan.completedHours,
                    remaining: plan.remainingHours,
                    total: plan.totalHours,
                  ),
                  SizedBox(height: 16.h),
                  ...items.map(
                    (course) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _PlanCourseCard(course: course),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<StudyPlanCourseModel> _planItems(StudyPlanModel plan) {
    if (plan.semesters.isNotEmpty) {
      return plan.semesters.expand((semester) => semester.courses).toList();
    }
    return plan.courses;
  }
}

class _SummaryRow extends StatelessWidget {
  final int completed;
  final int remaining;
  final int total;

  const _SummaryRow({
    required this.completed,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(label: 'المكتمل', value: '$completed ساعة')),
        SizedBox(width: 8.w),
        Expanded(child: _SummaryCard(label: 'المتبقي', value: '$remaining ساعة')),
        SizedBox(width: 8.w),
        Expanded(child: _SummaryCard(label: 'الإجمالي', value: '$total ساعة')),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffE3E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xff5D5F6F))),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PlanCourseCard extends StatelessWidget {
  final StudyPlanCourseModel course;

  const _PlanCourseCard({required this.course});

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
            course.courseCode,
            style: TextStyle(
              color: const Color(0xFF1564BF),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            course.courseTitle,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text('${course.creditHours} ساعات', style: TextStyle(fontSize: 12.sp)),
              SizedBox(width: 12.w),
              Text(course.status, style: TextStyle(fontSize: 12.sp, color: const Color(0xff5D5F6F))),
              if (course.semesterName.isNotEmpty) ...[
                SizedBox(width: 12.w),
                Text(course.semesterName, style: TextStyle(fontSize: 12.sp, color: const Color(0xff5D5F6F))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
