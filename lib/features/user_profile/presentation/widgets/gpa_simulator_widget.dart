// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/logic/helper_method.dart';
// import '../../../../core/ui/filledbutton.dart';
// import '../../../gpacalculator/view.dart';
//
// class GPASimulatorCard extends StatelessWidget {
//   const GPASimulatorCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 343.h,
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12.r),
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFF1461B8),
//             Color(0xFF75AEF0),
//           ],
//           stops: [0.0, 0.83],
//         ),
//       ),
//       child: Column(
//         children: [
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         "What-If GPA Simulator",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.calculate_rounded,
//                       color: Colors.white,
//                       size: 40.w,
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 16.h),
//                 Text(
//                   "المعدل المتوقع",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//
//                 SizedBox(height: 8.h),
//
//                 SizedBox(
//                   height: 42.h,
//                   child: TextField(
//                     decoration: _inputDecoration(),
//                   ),
//                 ),
//
//                 SizedBox(height: 12.h),
//
//                 Text(
//                   "عدد مقررات الفصل الحالى",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//
//                 SizedBox(height: 8.h),
//
//                 SizedBox(
//                   height: 42.h,
//                   child: TextField(
//                     decoration: _inputDecoration(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           CustomFilledButton(
//             text: "احسب المعدل",
//             width: 334,
//             height: 48,
//             radius: 16,
//             onPressed: () {
//               goTo(const GPACalculatorView());
//             },
//           ),
//
//           SizedBox(height: 8.h),
//         ],
//       ),
//     );
//   }

//   //text field
//   static InputDecoration _inputDecoration() {
//     return InputDecoration(
//       filled: true,
//       fillColor: const Color(0xFFFDFDFC),
//       contentPadding:
//       EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8.r),
//         borderSide: const BorderSide(
//           color: Color(0xFFE3E4E8),
//           width: 1,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8.r),
//         borderSide: const BorderSide(
//           color: Color(0xFF1564BF),
//           width: 1,
//         ),
//       ),
//     );
//   }
// }
