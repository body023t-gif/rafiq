import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_state.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'package:rafiq/features/auth/data/models/sign_in_command.dart';
import 'package:rafiq/features/auth/helpers/auth_text_style.dart';
import 'package:rafiq/features/auth/helpers/auth_colors.dart';
import 'package:rafiq/features/auth/presentation/widgets/custom_text_field.dart';
import 'reset_password_screen.dart';
import 'package:rafiq/features/dashboard/presentation/screens/home_screen.dart';
import 'package:rafiq/core/network/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafiq/core/ui/snackbar_service.dart';
import 'confirmation_code_screen.dart';

class InitialLogin extends StatefulWidget {
  const InitialLogin({super.key});

  @override
  State<InitialLogin> createState() => _InitialLoginState();
}

class _InitialLoginState extends State<InitialLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordStep = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      setState(() {
        rememberMe = true;
        emailController.text = prefs.getString('remember_email') ?? '';
        passwordController.text = prefs.getString('remember_password') ?? '';
        isPasswordStep = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: const BackButton(color: Colors.black),
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthLoading ||
              current is AuthSuccess ||
              current is AuthError,
          listener: (context, state) {
            if (state is AuthSuccess) {
              // Save to SessionManager
              SessionManager().saveSession(state.data);

              // Save remember me credentials if enabled
              SharedPreferences.getInstance().then((prefs) {
                if (rememberMe) {
                  prefs.setBool('remember_me', true);
                  prefs.setString('remember_email', emailController.text.trim());
                  prefs.setString('remember_password', passwordController.text.trim());
                } else {
                  prefs.remove('remember_me');
                  prefs.remove('remember_email');
                  prefs.remove('remember_password');
                }
              });

              // Print dynamic session verification
              log('================= Login Session Verified =================');
              log('User ID: ${state.data.id}');
              log('Role: ${state.data.roles}');
              log('Email: ${state.data.email}');
              log('Token exists?: ${state.data.token != null}');
              log('Refresh token exists?: ${state.data.refreshToken != null}');
              log('==========================================================');

              SnackbarService.showSuccessSnackBar('تم تسجيل الدخول بنجاح');
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            }
            if (state is AuthError) {
              final errText = state.error.replaceAll('ApiException: ', '');
              log('DEBUG [InitialLogin]: Received AuthError state.');
              log('DEBUG [InitialLogin]: Error Text = $errText');
              
              if (errText.contains('Email is not activated yet')) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmationCodeScreen(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ),
                    ),
                  );
                }
              } else {
                SnackbarService.showErrorSnackBar(errText);
              }
            }
          },
          child: Builder(builder: (context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 100),
                      Text('تسجيل الدخول',
                          style: TextStyles.loginHeadline,
                          textAlign: TextAlign.right),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 250,
                        child: Text('ادخل لحسابك واستكمل مشوارك الدراسي',
                            style: TextStyles.loginsubtitle,
                            textAlign: TextAlign.right),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: SizedBox(
                          width: 335,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextField(
                                controller: emailController,
                                hintText: 'ادخل البريد الإلكتروني',
                                suffixIcon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 10),
                              if (!isPasswordStep) ...[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: 8),
                                  child: Text(
                                      'سيتم ارسال كلمة المرور إلى بريدك الإلكترونى',
                                      style: TextStyles.loginsubtitle,
                                      textAlign: TextAlign.right),
                                ),
                              ] else ...[
                                CustomTextField(
                                  controller: passwordController,
                                  hintText: 'كلمة المرور',
                                  suffixIcon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('تذكرني',
                                        style: TextStyle(
                                            fontFamily: 'IBMPlexSansArabic',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    Checkbox(
                                      value: rememberMe,
                                      activeColor: AppColors.primary,
                                      onChanged: (value) async {
                                        setState(() {
                                          rememberMe = value ?? false;
                                        });
                                        if (!rememberMe) {
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.remove('remember_me');
                                          await prefs.remove('remember_email');
                                          await prefs.remove('remember_password');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 28),
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (emailController.text.isEmpty) {
                                                SnackbarService.showErrorSnackBar('برجاء إدخال البريد الإلكتروني');
                                                return;
                                              }
                                              if (!isPasswordStep) {
                                                setState(() {
                                                  isPasswordStep = true;
                                                });
                                              } else {
                                                if (passwordController.text.isEmpty) {
                                                  SnackbarService.showErrorSnackBar('برجاء إدخال كلمة المرور');
                                                  return;
                                                }
                                                context.read<AuthCubit>().login(
                                                      SignInCommand(
                                                        email: emailController.text.trim(),
                                                        password: passwordController.text.trim(),
                                                      ),
                                                    );
                                              }
                                            },
                                      child: isLoading
                                          ? const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'جاري تسجيل الدخول...',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontFamily: 'IBMPlexSansArabic',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              isPasswordStep ? 'تسجيل الدخول' : 'التالي',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'IBMPlexSansArabic',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (isPasswordStep)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontFamily: 'IBMPlexSansArabic',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
