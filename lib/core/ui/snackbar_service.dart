import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final state = messengerKey.currentState;
    if (state == null) return;

    // Hide any currently visible snackbars immediately before showing a new one
    state.hideCurrentSnackBar();

    state.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            color: Colors.white,
          ),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: backgroundColor ?? const Color(0xFF1E293B),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red.shade600,
    );
  }

  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green.shade600,
    );
  }
}
