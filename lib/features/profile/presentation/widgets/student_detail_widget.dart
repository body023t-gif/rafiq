// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class StudentDetails extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final String? Function(String?)? validator;
//   final TextInputType keyboardType;
//
//
//   const StudentDetails({
//     super.key,
//     required this.label,
//     required this.controller,
//     this.validator,
//     this.keyboardType = TextInputType.text,
//
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       validator: validator,
//       keyboardType: keyboardType,
//       textDirection: TextDirection.rtl,
//       textAlign: TextAlign.right,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle:  TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w400,
//           color: Color(0xFF1564BF),
//         ),
//         enabledBorder:  UnderlineInputBorder(
//           borderSide: BorderSide(
//             color: Color(0xFF1564BF),
//             width: 2.w,
//           ),
//         ),
//         focusedBorder:  UnderlineInputBorder(
//           borderSide: BorderSide(
//             color: Color(0xFF1564BF),
//             width: 2.w,
//           ),
//         ),
//       ),
//     );
//
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentDetails extends StatelessWidget {
  final String label;
  final String value;

  const StudentDetails({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1564BF),
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF1564BF),
                width: 2.w,
              ),
            ),
          ),
          child: Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
