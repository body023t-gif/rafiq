import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/network/api_service.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/ai_assistant_cubit.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/career_cubit.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/career_state.dart';
import 'package:rafiq/features/chat%20ai/models/career_suggestion_model.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_state.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final studentId = ApiService.dynamicStudentId;
    if (studentId != null && studentId.isNotEmpty) {
      context.read<CareerCubit>().loadCareerSuggestions(studentId);
    } else {
      final profileCubit = context.read<ProfileCubit>();
      if (profileCubit.state is ProfileLoaded) {
        final profile = (profileCubit.state as ProfileLoaded).profile;
        ApiService.dynamicStudentId = profile.id;
        context.read<CareerCubit>().loadCareerSuggestions(profile.id);
      } else {
        profileCubit.loadProfile().then((_) {
          final loadedStudentId = ApiService.dynamicStudentId;
          if (loadedStudentId != null && loadedStudentId.isNotEmpty) {
            if (mounted) {
              context.read<CareerCubit>().loadCareerSuggestions(loadedStudentId);
            }
          } else {
            if (mounted) {
              context.read<CareerCubit>().loadCareerSuggestions('');
            }
          }
        });
      }
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year/$month/$day';
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
          padding: EdgeInsets.only(right: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "اقتراحات مسار المهنة",
              style: TextStyle(
                color: Color(0xff212529),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ),
        ),
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xff1564BF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<CareerCubit, CareerState>(
          listener: (context, state) {
            if (state is CareerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CareerLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: Color(0xff1564BF),
                  ),
                ),
              );
            } else if (state is CareerError) {
              return RefreshIndicator(
                color: const Color(0xff1564BF),
                onRefresh: () async {
                  _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildErrorState(state.message),
                  ),
                ),
              );
            } else if (state is CareerEmpty) {
              return RefreshIndicator(
                color: const Color(0xff1564BF),
                onRefresh: () async {
                  _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildEmptyState(),
                  ),
                ),
              );
            } else if (state is CareerLoaded) {
              final suggestions = state.suggestions;
              return RefreshIndicator(
                color: const Color(0xff1564BF),
                onRefresh: () async {
                  _loadData();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return _buildCareerCard(context, suggestion);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.school_outlined,
          size: 80,
          color: Color(0xffB0BEC5),
        ),
        const SizedBox(height: 24),
        const Text(
          "لا توجد اقتراحات مهنية متاحة حالياً.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff212529),
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "سيتم عرض اقتراحات المسارات المهنية بعد تفعيل الخدمة من قبل النظام.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff707070),
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline,
          size: 80,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 24),
        const Text(
          "فشل تحميل الاقتراحات المهنية",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff212529),
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff707070),
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text(
            "إعادة المحاولة",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff1564BF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCareerCard(
    BuildContext context,
    CareerSuggestionModel suggestion,
  ) {
    final formattedDate = _formatDate(suggestion.createdAt);
    return InkWell(
      onTap: () {
        context.read<AiAssistantCubit>().saveCareer(suggestion.careerPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم اختيار مسار: ${suggestion.careerPath}"),
            backgroundColor: const Color(0xff1564BF),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(200, 200, 200, 1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    suggestion.careerPath,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xff707070),
                      fontSize: 12,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              suggestion.justification,
              style: const TextStyle(
                color: Color(0xff707070),
                fontSize: 13,
                fontFamily: 'IBMPlexSansArabic',
                height: 1.4,
              ),
            ),
            if (suggestion.trackConfidence.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "نسبة الثقة: ${suggestion.trackConfidence}",
                style: const TextStyle(
                  color: Color(0xff1564BF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
            ],
            if (suggestion.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: Color.fromRGBO(200, 200, 200, 1)),
              const SizedBox(height: 8),
              const Text(
                "المقررات الموصى بها:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: Color(0xff212529),
                ),
              ),
              const SizedBox(height: 8),
              ...suggestion.recommendations.map((rec) {
                log('[CareerScreen] Rendering recommendation: ${rec.courseCode} - ${rec.title}');
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffE9ECEF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (rec.courseCode.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xff1564BF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rec.courseCode,
                                style: const TextStyle(
                                  color: Color(0xff1564BF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              rec.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBMPlexSansArabic',
                                color: Color(0xff495057),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (rec.confidence.isNotEmpty || rec.score.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            if (rec.confidence.isNotEmpty)
                              Text(
                                'نسبة الثقة: ${rec.confidence}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1564BF),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            if (rec.score.isNotEmpty)
                              Text(
                                'التقييم: ${rec.score}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1564BF),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
