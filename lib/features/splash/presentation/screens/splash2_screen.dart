import 'package:flutter/material.dart';
import 'package:rafiq/features/auth/helpers/auth_text_style.dart';
import 'package:rafiq/features/auth/presentation/widgets/custom_button.dart';
import 'package:rafiq/features/auth/presentation/widgets/step_indicator.dart';
import 'package:rafiq/features/auth/helpers/auth_constants.dart';
import 'splash3_screen.dart';

class Splash2 extends StatelessWidget {
  const Splash2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 460),
                const SizedBox(height: 5),
                const StepIndicator(currentIndex: 1),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        Constants.splash2Title,
                        style: TextStyles.headline.copyWith(
                          color: const Color(0xFF0C0C0E),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        Constants.splash2Subtitle,
                        style: TextStyles.subtitle.copyWith(
                          color: const Color(0xFF676F72),
                          fontSize: 18,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Center(
                    child: SizedBox(
                      width: 167,
                      height: 46,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CustomButton(
                          text: 'التالي',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Splash3(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 180,
            left: (MediaQuery.of(context).size.width - 314) / 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                Constants.splash2Image,
                width: 314,
                height: 297,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 83.5,
            left: 33,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1564BF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
