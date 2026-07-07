import 'package:flutter/material.dart';
import 'auth_colors.dart';

class TextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: "IBMPlexSansArabic",
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle loginHeadline = headline.copyWith(
    fontSize: 38,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 38 * -0.04,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: "IBMPlexSansArabic",
    color: Color.fromARGB(93, 95, 111, 1),
    height: 1.5,
  );

  static TextStyle loginsubtitle = subtitle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 38 * -0.04,
    color: const Color(0xFFACADB9),
  );
  static const TextStyle label = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: "IBMPlexSansArabic",
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: "IBMPlexSansArabic",
    color: Colors.white,
  );

  static const TextStyle smallText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: "IBMPlexSansArabic",
    color: AppColors.textSecondary,
  );
}
