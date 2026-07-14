import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/auth/helpers/auth_text_style.dart';
import 'package:rafiq/features/auth/helpers/auth_colors.dart';
import 'package:rafiq/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:rafiq/features/auth/presentation/cubit/auth_state.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'package:rafiq/features/auth/data/models/reset_password_command.dart';
import 'initial_login_screen.dart';
import 'package:rafiq/core/ui/snackbar_service.dart';

class NewPassword extends StatefulWidget {
  final String userEmail;
  const NewPassword({super.key, required this.userEmail});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isTokenFormatValid = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.userEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    tokenController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _verifyTokenFormat() {
    final token = tokenController.text.trim();
    if (token.isEmpty) {
      SnackbarService.showErrorSnackBar("برجاء إدخال رمز التحقق");
      return;
    }
    
    setState(() {
      _isTokenFormatValid = true;
    });
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
          leading: const BackButton(color: Colors.black),
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              SnackbarService.showSuccessSnackBar("تمت إعادة تعيين كلمة المرور بنجاح.");
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InitialLogin(),
                  ),
                  (route) => false,
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
                        const SizedBox(height: 50),
                        Center(
                          child: Text(
                            'إعادة تعيين كلمة المرور',
                            style: TextStyles.loginHeadline,
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'البريد الإلكتروني',
                          suffixIcon: Icons.mail_outline,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: tokenController,
                          hintText: 'رمز التحقق (Token)',
                          suffixIcon: Icons.key_outlined,
                          readOnly: _isTokenFormatValid,
                        ),
                        
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isTokenFormatValid
                              ? Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: passwordController,
                                      hintText: 'كلمة المرور الجديدة',
                                      suffixIcon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: confirmPasswordController,
                                      hintText: 'تأكيد كلمة المرور الجديدة',
                                      suffixIcon: Icons.lock_outline,
                                      isPassword: true,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (!_isTokenFormatValid) {
                                      _verifyTokenFormat();
                                    } else {
                                      final token = tokenController.text.trim();
                                      final password = passwordController.text.trim();
                                      final confirmPassword = confirmPasswordController.text.trim();

                                      if (password.isEmpty) {
                                        SnackbarService.showErrorSnackBar("برجاء إدخال كلمة المرور الجديدة");
                                        return;
                                      }
                                      if (password != confirmPassword) {
                                        SnackbarService.showErrorSnackBar("كلمتا المرور غير متطابقتين");
                                        return;
                                      }

                                      context.read<AuthCubit>().resetPassword(
                                            ResetPasswordCommand(
                                              email: widget.userEmail,
                                              token: token,
                                              newPassword: password,
                                            ),
                                          );
                                    }
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
                                : Text(
                                    _isTokenFormatValid ? 'حفظ' : 'التحقق من الرمز',
                                    style: TextStyles.buttonText,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
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
