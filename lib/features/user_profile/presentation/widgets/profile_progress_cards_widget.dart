// import 'package:flutter/material.dart';
// class ProgressCards extends StatelessWidget {
//   final List<String> labels = [
//     "معدلك الحالي",
//     "الصف الدراسي",
//     "الساعات المكتملة",
//     "الساعات المتبقية",
//     "المرشد الأكاديمي"
//   ];
//
//   final List<String> apiProgressCards;
//
//   ProgressCards({super.key, required this.apiProgressCards});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double spacing = 10;
//         double totalWidth = constraints.maxWidth;
//         double cardWidth = (totalWidth - spacing) / 2;
//
//         return Wrap(
//           spacing: spacing,
//           runSpacing: spacing,
//           children: List.generate(labels.length, (index) {
//             bool isLast = index == labels.length - 1;
//
//             return Container(
//               width: isLast ? totalWidth : cardWidth,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xffE8F2FC),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     labels[index],
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF9092A2),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     apiProgressCards.length > index
//                         ? apiProgressCards[index]
//                         : "0",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight:
//                       isLast ? FontWeight.w500 : FontWeight.w600,
//                       color: isLast ? Colors.black : const Color(0xFF1564BF),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         );
//       },
// //     );
// //   }
// // }
//  import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class ProgressCards extends StatelessWidget {
//   final List<String> labels = [
//     "معدلك الحالي",
//     "الصف الدراسي",
//     "الساعات المكتملة",
//     "الساعات المتبقية",
//     "المرشد الأكاديمي"
//   ];
//
//   final List<String> apiProgressCards;
//
//   ProgressCards({super.key, required this.apiProgressCards});
//
//   @override
//   Widget build(BuildContext context) {
//     double spacing = 10.w;
//
//     Widget buildCard(int index, {double? width}) {
//       return Container(
//         width: width,
//         padding:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
//         decoration: BoxDecoration(
//           color: const Color(0xffE8F2FC),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               labels[index],
//               style:  TextStyle(
//                 fontSize: 12.sp,
//                 color: Color(0xFF9092A2),
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//              SizedBox(height: 4.h),
//             Text(
//               apiProgressCards.length > index ? apiProgressCards[index] : "0",
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: index == 4 ? FontWeight.w500 : FontWeight.w600,
//                 color: index == 4 ? Colors.black : const Color(0xFF1564BF),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double cardWidth = (constraints.maxWidth - spacing) / 2;
//
//         return Column(
//           children: [
//             Row(
//               children: [
//                 buildCard(0, width: cardWidth),
//                 SizedBox(width: spacing),
//                 buildCard(1, width: cardWidth),
//               ],
//             ),
//             SizedBox(height: spacing),
//             Row(
//               children: [
//                 buildCard(2, width: cardWidth),
//                 SizedBox(width: spacing),
//                 buildCard(3, width: cardWidth),
//               ],
//             ),
//             SizedBox(height: spacing),
//             // البطاقة الخامسة بعرض كامل
//             buildCard(4, width: constraints.maxWidth),
//           ],
//         );
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'cubit/model.dart';
//
// class ProgressCards extends StatelessWidget {
//   final List<String> labels = [
//     "معدلك الحالي",
//     "الصف الدراسي",
//     "الساعات المكتملة",
//     "الساعات المتبقية",
//     "المرشد الأكاديمي"
//   ];
//
//   final StudentProgressModel progress;
//
//   ProgressCards({super.key,
//     required this.progress,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     double spacing = 10.w;
//
//     Widget buildCard(int index, {double? width}) {
//       return Container(
//         width: width,
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
//         decoration: BoxDecoration(
//           color: const Color(0xffE8F2FC),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           // 👆 مهم: يمنع الكارت من التمدد رأسيًا زيادة عن اللزوم
//           children: [
//             Text(
//               labels[index],
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: const Color(0xFF9092A2),
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               apiProgressCards.length > index
//                   ? apiProgressCards[index]
//                   : "0",
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight:
//                 index == 4 ? FontWeight.w500 : FontWeight.w600,
//                 color: index == 4
//                     ? Colors.black
//                     : const Color(0xFF1564BF),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double cardWidth =
//             (constraints.maxWidth - spacing) / 2;
//
//         return SizedBox(
//           width: constraints.maxWidth,
//           // 👆 مهم: بنحدد عرض صريح عشان LayoutBuilder ما يتلخبطش
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             // 👆 يمنع أي تمدد رأسي غير مطلوب
//             children: [
//               Row(
//                 children: [
//                   buildCard(0, width: cardWidth),
//                   SizedBox(width: spacing),
//                   buildCard(1, width: cardWidth),
//                 ],
//               ),
//               SizedBox(height: spacing),
//               Row(
//                 children: [
//                   buildCard(2, width: cardWidth),
//                   SizedBox(width: spacing),
//                   buildCard(3, width: cardWidth),
//                 ],
//               ),
//               SizedBox(height: spacing),
//               buildCard(4, width: constraints.maxWidth),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/user_profile/presentation/widgets/progresscards/cubit/model.dart';

class ProgressCards extends StatelessWidget {
  final StudentProgressModel progress;

  ProgressCards({
    super.key,
    required this.progress,
  });

  final List<String> labels = [
    "معدلك الحالي",
    "الصف الدراسي",
    "الساعات المكتملة",
    "الساعات المتبقية",
    "المرشد الأكاديمي"
  ];

  @override
  Widget build(BuildContext context) {
    double spacing = 10.w;

    String valueByIndex(int index) {
      switch (index) {
        case 0:
          return progress.gpa.toStringAsFixed(2);
        case 1:
          return progress.level;
        case 2:
          return "${progress.completedHours}";
        case 3:
          return "${progress.remainingHours}";
        case 4:
          return progress.advisorName;
        default:
          return "0";
      }
    }

    Widget buildCard(int index, {double? width}) {
      return Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xffE8F2FC),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF9092A2),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              valueByIndex(index),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight:
                index == 4 ? FontWeight.w500 : FontWeight.w600,
                color: index == 4
                    ? Colors.black
                    : const Color(0xFF1564BF),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth =
            (constraints.maxWidth - spacing) / 2;

        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  buildCard(0, width: cardWidth),
                  SizedBox(width: spacing),
                  buildCard(1, width: cardWidth),
                ],
              ),
              SizedBox(height: spacing),
              Row(
                children: [
                  buildCard(2, width: cardWidth),
                  SizedBox(width: spacing),
                  buildCard(3, width: cardWidth),
                ],
              ),
              SizedBox(height: spacing),
              buildCard(4, width: constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }
}
