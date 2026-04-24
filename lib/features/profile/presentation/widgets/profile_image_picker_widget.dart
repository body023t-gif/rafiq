import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPick;

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            /// Big circle
            CircleAvatar(
              radius: 80.r,
              backgroundColor: const Color(0xFF9092A2),
              backgroundImage: image != null ? FileImage(image!) : null,

            ),

            /// Small circle with camera icon
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: onPick,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFD1E4FA),
                  radius: 16.r,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: const Color(0xFF1564BF),
                    size: 18.r,
                  ),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }
}
