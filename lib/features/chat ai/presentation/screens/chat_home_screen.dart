import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/chat ai/data/datasource/ai_chat_remote_datasource.dart';
import 'package:rafiq/features/chat ai/repository/ai_chat_repository.dart';
import 'package:rafiq/features/chat ai/presentation/cubit/ai_assistant_cubit.dart';
import 'package:rafiq/features/chat ai/presentation/cubit/ai_assistant_state.dart';
import 'package:rafiq/features/welcome chat/presentation/widgets/welcome_chat.dart';
import 'package:rafiq/features/study%20plan/presentation/widgets/study_plan.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/career_cubit.dart';
import 'package:rafiq/features/chat%20ai/repository/career_repository.dart';
import 'package:rafiq/features/chat%20ai/data/datasource/career_remote_datasource.dart';
import 'ai_career_screen.dart';
import 'ai_gpa_screen.dart';


class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return BlocProvider(
      create: (context) {
        final apiService = createApiService();
        return AiAssistantCubit(
          AiChatRepository(AiChatRemoteDataSource(apiService)),
        );
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const CustomAppBar(title: 'مساعدك الذكي'),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 35, bottom: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      final aiCubit = BlocProvider.of<AiAssistantCubit>(context);
                                      final profileCubit = BlocProvider.of<ProfileCubit>(context);
                                      final apiService = createApiService();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => MultiBlocProvider(
                                                      providers: [
                                                        BlocProvider.value(value: aiCubit),
                                                        BlocProvider.value(value: profileCubit),
                                                        BlocProvider(
                                                          create: (_) => CareerCubit(
                                                            CareerRepository(
                                                              CareerRemoteDataSource(apiService),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      child: const CareerScreen())));
                                    },
                                    child: const _FeatureCard(
                                        icon: Icons.school_outlined,
                                        title: "اقتراحات مسار المهنة"))),
                            const SizedBox(width: 16),
                            Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      final aiCubit = BlocProvider.of<AiAssistantCubit>(context);
                                      final profileCubit = BlocProvider.of<ProfileCubit>(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => MultiBlocProvider(
                                                      providers: [
                                                        BlocProvider.value(value: aiCubit),
                                                        BlocProvider.value(value: profileCubit),
                                                      ],
                                                      child: const GpaScreen())));
                                    },
                                    child: const _FeatureCard(
                                        icon: Icons.calculate_outlined,
                                        title: "حاسبة المعدل"))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudyPlanView(),
                            ),
                          ),
                          child: const _WideFeatureCard(
                              icon: Icons.calendar_today_outlined,
                              title: "تحسين خطة الدراسة"),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeChatView(),
                            ),
                          ),
                          child: const _WideFeatureCard(
                              icon: Icons.chat_outlined,
                              title: "الشات الذكي الكامل"),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<AiAssistantCubit, AiAssistantState>(
                          builder: (context, state) {
                            if (state is AiLoadingState) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (state is AiSuccessState) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFEDF4FF),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text(state.response['answer'] ?? state.response['data']?['answer'] ?? "",
                                    style: const TextStyle(
                                        fontFamily: 'IBMPlexSansArabic')),
                              );
                            }
                            return _ChatBanner();
                          },
                        ),
                        const SizedBox(height: 20),
                        _TipCard(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                              hintText: "اسأل رفيق...",
                              filled: true,
                              fillColor: const Color(0xFFEDF4FF),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF1564BF)),
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            context
                                .read<AiAssistantCubit>()
                                .sendMessage(controller.text, "");
                            controller.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                _FloatingBottomNav(),
              ],
            ),
          );
        }
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FeatureCard({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 125,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFE6F0FF),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1564BF)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ));
  }
}

class _WideFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _WideFeatureCard({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFFE6F0FF),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Icon(icon, color: const Color(0xFF1564BF)),
            ]));
  }
}

class _ChatBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeChatView()),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFF1564BF), borderRadius: BorderRadius.circular(16)),
          child: const Text(
            "اسأل رفيق! (اضغط هنا لفتح الدردشة الكاملة)",
            style: TextStyle(color: Colors.white, fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16)),
        child: const Text(
          "نصيحة: ذاكر بذكاء! رتّب أولوياتك الدراسية وحافظ على قسط كافٍ من النوم.",
          style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
          textAlign: TextAlign.right,
        ));
  }
}

class _FloatingBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 30);
  }
}
