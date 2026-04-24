import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final double? width;
  final double? height;
  final double? radius;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const CustomFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.radius,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? double.infinity,
        height: height ?? 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor:
            backgroundColor ?? const Color(0xFF1564BF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 14),
            ),
          ),
          child: Text(
            text,
            style: textStyle ??
                Theme.of(context)
                    .filledButtonTheme
                    .style
                    ?.textStyle
                    ?.resolve({}),
          ),
        ),
      ),
    );
  }
}
