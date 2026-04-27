import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_service.dart';
import 'package:rafiq/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:rafiq/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:rafiq/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:rafiq/features/dashboard/presentation/widgets/academic_summary_cards_widget.dart';
import 'package:rafiq/features/dashboard/presentation/widgets/gpa_progress_widget.dart';
import 'package:rafiq/features/dashboard/presentation/widgets/plan_progress_card_widget.dart';
import 'package:rafiq/features/dashboard/presentation/widgets/welcome_card_widget.dart';
import 'package:rafiq/features/dashboard/repository/dashboard_repository.dart';
import 'package:rafiq/core/ui/appbar.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;

  const DashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit(
      DashboardRepository(
        DashboardRemoteDataSource(
          ApiService(
            baseUrl: const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'https://rafeek-live.runasp.net',
            ),
            acceptLanguage: const String.fromEnvironment(
              'ACCEPT_LANGUAGE',
              defaultValue: '',
            ).isEmpty
                ? null
                : const String.fromEnvironment('ACCEPT_LANGUAGE'),
          ),
        ),
      ),
    )..loadDashboard(ApiService.staticUserId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "لوحة التحكم"),
      body: BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    SizedBox(height: 12.h),
                    FilledButton(
                      onPressed: () =>
                          context.read<DashboardCubit>().retry(ApiService.staticUserId),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final dashboard = (state as DashboardLoaded).dashboard;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      WelcomeCard(firstName: dashboard.firstName),
                      SizedBox(height: 20.h),
                      AcademicSummaryCards(
                        earnedHours: dashboard.earnedHours,
                        cgpa: dashboard.cgpa,
                      ),
                      SizedBox(height: 20.h),
                      GPAProgress(progressPoints: dashboard.gpaProgress),
                      SizedBox(height: 20.h),
                      PlanProgressCard(
                        completedCourses: dashboard.planProgress.completedCourses,
                        remainingCourses: dashboard.planProgress.remainingCourses,
                        universityRequirementsPercentage:
                            dashboard.planProgress.universityRequirementsPercentage,
                        majorRequirementsPercentage:
                            dashboard.planProgress.majorRequirementsPercentage,
                        electiveRequirementsPercentage:
                            dashboard.planProgress.electiveRequirementsPercentage,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
