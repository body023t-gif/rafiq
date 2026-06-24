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
