import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_state.dart';
import 'package:rafiq/features/profile/presentation/widgets/profile_image_picker_widget.dart';
import 'package:rafiq/features/profile/presentation/widgets/student_detail_widget.dart';
import 'package:rafiq/features/profile/repository/profile_repository.dart';
import 'package:rafiq/features/user_profile/presentation/screens/user_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? selectedImage;
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit(
      ProfileRepository(
        ProfileRemoteDataSource(createApiService()),
      ),
    )..loadProfile();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider.value(
        value: _cubit,
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) async {
            if (state is ProfileLoaded) {
              final profile = state.profile;
              final prefs = await SharedPreferences.getInstance();
              final isCompleteFlag = prefs.getBool('profile_completed_${profile.id}') ?? false;

              if (isCompleteFlag) {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        profile: profile,
                        userImage: selectedImage,
                      ),
                    ),
                  );
                }
              }
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.message, textAlign: TextAlign.center),
                    ),
                    FilledButton(
                      onPressed: () => context.read<ProfileCubit>().retry(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final profile = (state as ProfileLoaded).profile;
            final names = _splitName(profile.fullName);
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 56.h),
                    Center(
                      child: ProfileImagePicker(
                        image: selectedImage,
                        onPick: () async {
                          final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            if (!mounted) return;
                            setState(() => selectedImage = File(picked.path));
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFFFEBAA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFF856404)),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              "البيانات الأكاديمية يتم إدارتها وتحديثها بواسطة شؤون الطلاب فقط ولا يمكن تعديلها من التطبيق.",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF856404),
                                fontFamily: 'IBMPlexSansArabic',
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    StudentDetails(label: "الاسم الأول", value: names.$1),
                    SizedBox(height: 24.h),
                    StudentDetails(label: "الاسم الأخير", value: names.$2),
                    SizedBox(height: 24.h),
                    StudentDetails(label: "كود الطالب", value: profile.universityCode),
                    SizedBox(height: 24.h),
                    StudentDetails(label: "القسم", value: profile.departmentName),
                    SizedBox(height: 64.h),
                    CustomFilledButton(
                      text: "متابعة إلى لوحة التحكم",
                      width: double.infinity,
                      height: 56.h,
                      radius: 14.r,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('profile_completed_${profile.id}', true);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                profile: profile,
                                userImage: selectedImage,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

(String, String) _splitName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.sublist(1).join(' '));
}
