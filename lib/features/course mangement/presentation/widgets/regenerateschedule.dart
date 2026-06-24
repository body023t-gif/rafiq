import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/core/ui/filledbutton.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_cubit.dart';

class RegenerateScheduleSheet extends StatefulWidget {
  final List<String> courseIds;

  const RegenerateScheduleSheet({
    super.key,
    this.courseIds = const [],
  });

  @override
  State<RegenerateScheduleSheet> createState() => _RegenerateScheduleSheetState();
}

class _RegenerateScheduleSheetState extends State<RegenerateScheduleSheet> {
  int _selectedIndex = 0;

  TimetableStrategy get _strategy =>
      _selectedIndex == 0 ? TimetableStrategy.compact : TimetableStrategy.balanced;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Column(
              children: [
                Text(
                  'إعادة إنشاء الجدول الدراسي',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'حدد استراتيجية تحسين للجدول',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildOptionCard(
            index: 0,
            title: 'جدول مضغوط',
            subtitle: 'تقليل أيام في الحرم الجامعي',
            icon: Icons.grid_view_rounded,
          ),
          SizedBox(height: 12.h),
          _buildOptionCard(
            index: 1,
            title: 'أفضل توازن التحميل',
            subtitle: 'توزيع متكافئ للجدول الدراسي',
            icon: Icons.balance_outlined,
          ),
          SizedBox(height: 24.h),
          CustomFilledButton(
            icon: Icons.auto_awesome_outlined,
            text: 'إعادة توليد جدول جديد',
            width: double.infinity,
            height: 48.h,
            radius: 14.r,
            onPressed: () async {
              Navigator.pop(context);
              await context.read<TimetableCubit>().regenerate(
                    strategy: _strategy,
                    courseIds: widget.courseIds,
                  );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedIndex == index;
    final borderColor = isSelected ? const Color(0xFF1564BF) : Colors.grey.shade300;
    final backgroundColor = isSelected ? const Color(0xFFE8F1FB) : Colors.white;
    final iconBgColor = isSelected ? const Color(0xFF1564BF) : const Color(0xFFDCEBFC);
    final iconColor = isSelected ? Colors.white : const Color(0xFF1564BF);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF1564BF) : Colors.grey.shade400,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}
