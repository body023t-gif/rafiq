import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rafiq/features/profile/presentation/screens/profile_screen.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_state.dart';
import 'package:rafiq/features/profile/repository/profile_repository.dart';
import 'package:rafiq/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:rafiq/features/course mangement/presentation/widgets/courses.dart';
import 'package:rafiq/features/course mangement/presentation/cubit/schedule_cubit.dart';
import 'package:rafiq/features/course mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course mangement/repository/schedule_repository.dart';
import 'package:rafiq/features/course mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/chat ai/presentation/screens/chat_home_screen.dart';
import 'package:rafiq/features/academic_calendar/presentation/screens/academic_calendar_screen.dart';
import 'package:rafiq/features/student_services/presentation/screens/student_services_screen.dart';
import 'package:rafiq/features/student_services/presentation/screens/college_building_map_screen.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_cubit.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_state.dart';
import 'package:rafiq/features/academic_calendar/repository/reminder_repository.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';

import 'package:rafiq/features/course mangement/repository/timetable_repository.dart';
import 'package:rafiq/features/course mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course mangement/models/timetable_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileCubit _profileCubit;
  late final ScheduleCubit _scheduleCubit;
  late final ReminderCubit _reminderCubit;

  @override
  void initState() {
    super.initState();
    final apiService = createApiService();
    _profileCubit = ProfileCubit(
      ProfileRepository(ProfileRemoteDataSource(apiService)),
    )..loadProfile();
    _scheduleCubit = ScheduleCubit(
      ScheduleRepository(ScheduleRemoteDataSource(apiService)),
    )..loadSchedule();
    _reminderCubit = ReminderCubit(
      ReminderRepository(ReminderRemoteDataSource(apiService)),
    );
    if (_reminderCubit.state is ReminderInitial) {
      _reminderCubit.loadReminders();
    }

    // Startup debug trace
    Future.delayed(const Duration(seconds: 5), () {
      log("--- STARTING TIMETABLE GENERATION STARTUP TRACE ---");
      final repo = TimetableRepository(TimetableRemoteDataSource(apiService));
      repo.generateTimetable(TimetableRequestModel(
        strategy: TimetableStrategy.compact,
        courseIds: ['ebfc8dba-f785-41d1-b8c5-16caa90ea982'],
      )).then((res) {
        log("Startup trace generation success: $res");
      }).catchError((e) {
        log("Startup trace generation error: $e");
      });
    });
  }

  @override
  void dispose() {
    _profileCubit.close();
    _scheduleCubit.close();
    _reminderCubit.close();
    super.dispose();
  }

  void _retry() {
    _profileCubit.loadProfile();
    _scheduleCubit.loadSchedule();
    _reminderCubit.loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: _scheduleCubit),
        BlocProvider.value(value: _reminderCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, scheduleState) {
                // 1. Loading State
                if (profileState is ProfileLoading || scheduleState is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error State
                if (profileState is ProfileError || scheduleState is ScheduleError) {
                  final String errorMsg;
                  if (profileState is ProfileError) {
                    errorMsg = profileState.message;
                  } else if (scheduleState is ScheduleError) {
                    errorMsg = scheduleState.message;
                  } else {
                    errorMsg = 'Failed to load data.';
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red, size: 48.sp),
                          const SizedBox(height: 16),
                          Text(
                            errorMsg,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E61BD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 3. Success State
                String studentName = "طالبي العزيز";
                String gpaVal = "-";
                String registeredCountVal = "-";
                String? profilePicUrl;

                if (profileState is ProfileLoaded) {
                  final profile = profileState.profile;
                  studentName = profile.fullName.trim();
                  gpaVal = profile.cumulativeGpa?.toStringAsFixed(2) ?? "-";
                  if (profile.profilePictureUrl.isNotEmpty &&
                      profile.profilePictureUrl != "string") {
                    profilePicUrl = profile.profilePictureUrl;
                  }
                }

                if (scheduleState is ScheduleLoaded) {
                  registeredCountVal = scheduleState.schedule.registeredCoursesCount.toString();
                } else if (scheduleState is ScheduleEmpty) {
                  registeredCountVal = "0";
                }

                return Stack(children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _HeaderSection(
                            studentName: studentName,
                            gpa: gpaVal,
                            registeredCourses: registeredCountVal,
                            profilePicUrl: profilePicUrl,
                          ),
                          const SizedBox(height: 10),
                          const _ServicesGrid(),
                          const SizedBox(height: 20),
                          const _ChatBanner(),
                          const SizedBox(height: 20),
                          const _EventsSection(),
                          const SizedBox(height: 20),
                          const _MapSection(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                  const _FloatingBottomNav(),
                ]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String studentName;
  final String gpa;
  final String registeredCourses;
  final String? profilePicUrl;

  const _HeaderSection({
    required this.studentName,
    required this.gpa,
    required this.registeredCourses,
    this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1E61BD),
            borderRadius: BorderRadius.circular(28)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text("مرحباً بك", style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'IBMPlexSansArabic')),
                Text(studentName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'IBMPlexSansArabic'))
              ]),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
                child: profilePicUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
              )
            ])
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _StatItem(gpa, "GPA"),
            const _VerticalDivider(),
            _StatItem(registeredCourses, "مقررات")
          ])
        ]));
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.16,
            children: [
              _ServiceCard(
                icon: Icons.dashboard_rounded,
                title: "لوحة التحكم",
                sub: "اتطلع على تقدمك الأكاديمي",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(userId: ApiService.dynamicUserId ?? ApiService.staticUserId),
                    ),
                  );
                },
              ),
              _ServiceCard(
                icon: Icons.menu_book_rounded,
                title: "إدارة المقررات",
                sub: "اتطلع المقررات المتاحة لديك",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoursesView(),
                    ),
                  );
                },
              ),
              _ServiceCard(
                icon: Icons.groups_rounded,
                title: "الخدمات الطلابيه",
                sub: "اكتشف الخدمات المتاحة لديك",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentServicesScreen(),
                    ),
                  );
                },
              ),
              _ServiceCard(
                icon: Icons.account_circle_rounded,
                title: "الملف الشخصي",
                sub: "إدارة بياناتك الشخصية",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ]));
  }
}

class _ChatBanner extends StatelessWidget {
  const _ChatBanner();
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          final profileCubit = BlocProvider.of<ProfileCubit>(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BlocProvider.value(
                  value: profileCubit,
                  child: const ChatHomeScreen())));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF3A8DFF), Color(0xFF1E61BD)]),
                borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("رفيق الشات الذكي",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
                Text("اسأل عن شئ",
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'IBMPlexSansArabic'))
              ]),
              SizedBox(width: 15),
              Icon(Icons.psychology_outlined, color: Colors.white, size: 35)
            ])));
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final reminderCubit = context.read<ReminderCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: reminderCubit,
              child: const AcademicCalendarScreen(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F6FF),
            borderRadius: BorderRadius.circular(25)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
                Row(
                  children: [
                    const Text(
                      "المواعيد القادمة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_month, color: Color(0xFF1E61BD)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            BlocBuilder<ReminderCubit, ReminderState>(
              builder: (context, state) {
                if (state is ReminderLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is ReminderError) {
                  return Column(
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.read<ReminderCubit>().loadReminders(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  );
                }

                final reminders = state is ReminderLoaded
                    ? state.reminders
                    : const <Map<String, dynamic>>[];

                final now = DateTime.now();
                int completedCount = 0;
                int expiredCount = 0;
                int upcomingCount = 0;

                final List<Map<String, dynamic>> upcoming = [];

                for (final r in reminders) {
                  final title = r['title'] ?? 'Unnamed';
                  final id = r['id'] ?? 'No-ID';
                  final isCompleted = r['isCompleted'] ?? false;
                  final status = r['status'] ?? '';

                  if (isCompleted) {
                    completedCount++;
                    log('[Upcoming Appointments Filter] Filtered out reminder "$title" (ID: $id) because isCompleted is true.');
                    continue;
                  }

                  if (status.toString().toLowerCase() == 'completed') {
                    completedCount++;
                    log('[Upcoming Appointments Filter] Filtered out reminder "$title" (ID: $id) because status is Completed.');
                    continue;
                  }

                  try {
                    final dueDate = DateTime.parse(r['dueDate']);
                    if (dueDate.isBefore(now)) {
                      expiredCount++;
                      log('[Upcoming Appointments Filter] Filtered out reminder "$title" (ID: $id) because dueDate is in the past (Due: ${r['dueDate']}).');
                      continue;
                    }

                    upcomingCount++;
                    upcoming.add(r);
                  } catch (e) {
                    log('[Upcoming Appointments Filter] Filtered out reminder "$title" (ID: $id) because parsing dueDate failed: $e');
                  }
                }

                // Sort by nearest dueDate first
                upcoming.sort((a, b) {
                  final dateA = DateTime.parse(a['dueDate']);
                  final dateB = DateTime.parse(b['dueDate']);
                  return dateA.compareTo(dateB);
                });

                log('========== [Upcoming Appointments Filter Stats] ==========');
                log('API Endpoint: /v1/api/reminders/getall/pagginated');
                log('Total reminders: ${reminders.length}');
                log('Completed reminders: $completedCount');
                log('Expired/Past reminders: $expiredCount');
                log('Upcoming reminders: $upcomingCount');
                log('Rendered reminders: ${upcoming.length}');
                log('===========================================================');

                if (upcoming.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "لا توجد مواعيد قادمة.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) {
                    final item = upcoming[index];
                    final title = item['title'] ?? '';
                    String formattedTime = '';
                    try {
                      final date = DateTime.parse(item['dueDate']);
                      formattedTime = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                      if (item['description'] != null && item['description'].toString().isNotEmpty) {
                        formattedTime += " – ${item['description']}";
                      }
                    } catch (_) {}

                    return _EventItem(title, formattedTime);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav();
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 25,
        left: 40,
        right: 40,
        child: Container(
            height: 70,
            decoration: BoxDecoration(
                color: const Color(0xFF1E61BD),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha:0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ]),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white54, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.smart_toy_outlined, color: Colors.white54, size: 28),
                    onPressed: () {
                      final profileCubit = BlocProvider.of<ProfileCubit>(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BlocProvider.value(
                            value: profileCubit,
                            child: const ChatHomeScreen())),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      // Already on HomeScreen
                    },
                  )
                ])));
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic')),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'IBMPlexSansArabic'))
    ]);
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: Colors.white24);
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final VoidCallback onTap;
  const _ServiceCard({required this.icon, required this.title, required this.sub, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F6FF),
              borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E61BD),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20)),
            const Spacer(),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'IBMPlexSansArabic'))
          ])),
    );
  }
}

class _EventItem extends StatelessWidget {
  final String title, time;
  const _EventItem(this.title, this.time);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'IBMPlexSansArabic')),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'IBMPlexSansArabic'))
          ]),
          const SizedBox(width: 12),
          Container(
              width: 3,
              height: 35,
              decoration: BoxDecoration(
                  color: const Color(0xFF1E61BD),
                  borderRadius: BorderRadius.circular(10)))
        ]));
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection();
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CollegeBuildingMapScreen()),
          );
        },
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 100,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F6FF),
                borderRadius: BorderRadius.circular(25)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("خريطة الكلية",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'IBMPlexSansArabic')),
                        Text("استكشف مباني الكلية",
                            style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'IBMPlexSansArabic'))
                      ]),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/images/cis_map.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ])));
  }
}
