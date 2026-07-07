import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/auth/helpers/auth_colors.dart';
import 'package:rafiq/features/auth/helpers/auth_text_style.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'package:rafiq/features/auth/data/models/sign_in_command.dart';
import 'package:rafiq/features/dashboard/presentation/screens/home_screen.dart';
import 'package:rafiq/data/api/api_service.dart';

class ConfirmationCodeScreen extends StatefulWidget {
  final String email;
  final String password;

  const ConfirmationCodeScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<ConfirmationCodeScreen> createState() => _ConfirmationCodeScreenState();
}

class _ConfirmationCodeScreenState extends State<ConfirmationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _repository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _nextField(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyAndActivate() async {
    final code = _otpCode;
    if (code.length < 6) {
      setState(() {
        _errorMessage = 'الرجاء إدخال رمز تفعيل مكون من 6 أرقام';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // 1. Check confirmation code
      final isCodeValid = await _repository.checkConfirmationCode(widget.email, code);
      if (!isCodeValid) {
        throw Exception('كود التفعيل غير صالح. الرجاء المحاولة مرة أخرى.');
      }

      // 2. Activate university email
      final isActivated = await _repository.activateUniversityEmail(widget.email, code);
      if (!isActivated) {
        throw Exception('فشل تفعيل الحساب. الرجاء التواصل مع الدعم الفني.');
      }

      setState(() {
        _successMessage = 'تم تفعيل الحساب بنجاح! جاري تسجيل الدخول...';
      });

      // 3. Automatically perform login again
      final loginResponse = await _repository.login(
        SignInCommand(
          email: widget.email,
          password: widget.password,
        ),
      );

      // Store dynamic token and user ID
      ApiService.dynamicToken = loginResponse.token;
      ApiService.dynamicUserId = loginResponse.id;

      // Print login session info
      print('================= Login Session Verified (Activation) =================');
      print('User ID: ${loginResponse.id}');
      print('Role: ${loginResponse.roles}');
      print('Email: ${loginResponse.email}');
      print('Token exists?: ${loginResponse.token != null}');
      print('Refresh token exists?: ${loginResponse.refreshToken != null}');
      print('======================================================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تفعيل الحساب وتسجيل الدخول بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to HomeScreen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
        _successMessage = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    'تفعيل الحساب',
                    style: TextStyles.loginHeadline,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'تم إرسال رمز التفعيل المكون من 6 أرقام إلى:',
                    style: TextStyles.loginsubtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1E4FA)),
                    ),
                    child: Text(
                      widget.email,
                      style: const TextStyle(
                        color: Color(0xFF1E61BD),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // OTP inputs row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F2F37),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => _nextField(value, index),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                if (_errorMessage != null)
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'IBMPlexSansArabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_successMessage != null)
                  Center(
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'IBMPlexSansArabic',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 40),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 47,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyAndActivate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('تأكيد وتفعيل الحساب', style: TextStyles.buttonText),
                  ),
                ),

                const SizedBox(height: 20),

                // Resend Button (Disabled as backend resend code endpoint doesn't exist)
                Center(
                  child: TextButton(
                    onPressed: null, // Disabled
                    child: Text(
                      'إعادة إرسال الرمز (غير متوفر)',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
