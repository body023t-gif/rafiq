import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/profile/models/profile_model.dart';

class ProfileProgressCardsWidget extends StatelessWidget {
  final ProfileModel profile;

  const ProfileProgressCardsWidget({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final remainingHours = (profile.totalHours - profile.completedHours).clamp(0, profile.totalHours);
    final values = <String>[
      profile.currentGpa.toStringAsFixed(2),
      "المستوى ${profile.level}",
      '${profile.completedHours}',
      '$remainingHours',
      profile.academicAdvisorName,
    ];
    final labels = <String>[
      "معدلك الحالي",
      "الصف الدراسي",
      "الساعات المكتملة",
      "الساعات المتبقية",
      "المرشد الأكاديمي",
    ];

    Widget buildCard(int index, double width) {
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
              values[index],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: index == 4 ? FontWeight.w500 : FontWeight.w600,
                color: index == 4 ? Colors.black : const Color(0xFF1564BF),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.w;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Column(
          children: [
            Row(
              children: [
                buildCard(0, cardWidth),
                SizedBox(width: spacing),
                buildCard(1, cardWidth),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              children: [
                buildCard(2, cardWidth),
                SizedBox(width: spacing),
                buildCard(3, cardWidth),
              ],
            ),
            SizedBox(height: spacing),
            buildCard(4, constraints.maxWidth),
          ],
        );
      },
    );
  }
}
