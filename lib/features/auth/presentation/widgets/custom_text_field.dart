import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData suffixIcon;
  final bool isPassword;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62.31,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        textAlign: TextAlign.right,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: "IBMPlexSansArabic",
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),

          suffixIcon: Icon(
            suffixIcon,
            size: 24,
            color: const Color(0xFF757575),
          ),

          prefixIcon: const Icon(
            Icons.check,
            size: 22,
            color: Color(0xFF757575),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          filled: true,
          fillColor: Colors.white,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.84),
            borderSide: const BorderSide(
              width: 2,
              color: Color.fromRGBO(47, 47, 55, 1),
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.84),
            borderSide: const BorderSide(width: 2),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.84),
            borderSide: const BorderSide(
              width: 2,
              color: Color.fromRGBO(47, 47, 55, 1),
            ),
          ),
        ),
      ),
    );
  }
}
