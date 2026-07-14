import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/auth/helpers/auth_text_style.dart';
import 'package:rafiq/features/auth/helpers/auth_colors.dart';
import 'package:rafiq/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_state.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'new_password_screen.dart';
import 'package:rafiq/core/ui/snackbar_service.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              SnackbarService.showSuccessSnackBar(state.message);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPassword(
                      userEmail: emailController.text.trim(),
                    ),
                  ),
                );
              }
            } else if (state is AuthError) {
              SnackbarService.showErrorSnackBar(state.error.replaceAll('ApiException: ', ''));
            }
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            'إعادة تعيين كلمة المرور',
                            style: TextStyles.loginHeadline,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'الالكتروني المسجل بالنظام',
                          suffixIcon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'سيتم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
                          style: TextStyles.loginsubtitle,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 60),

                        // زر إرسال
                        SizedBox(
                          width: double.infinity,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final email = emailController.text.trim();
                                    if (email.isEmpty) {
                                      SnackbarService.showErrorSnackBar('برجاء إدخال البريد الإلكتروني');
                                      return;
                                    }
                                    context.read<AuthCubit>().forgotPassword(email);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('إرسال', style: TextStyles.buttonText),
                          ),
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
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
