import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';

class WeeklyTimetableGrid extends StatelessWidget {
  final List<ScheduleEntryModel> entries;

  const WeeklyTimetableGrid({super.key, required this.entries});

  final List<String> _days = const ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس"];
  final int _startHour = 8;
  final int _endHour = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaysHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeColumn(),
                Expanded(
                  child: Stack(
                    children: [
                      _buildGridLines(),
                      ..._buildEntryCards(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysHeader() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(width: 50.w), // Space for time column
          ..._days.map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return SizedBox(
      width: 50.w,
      child: Column(
        children: List.generate((_endHour - _startHour) + 1, (index) {
          final hour = _startHour + index;
          return Container(
            height: 60.h,
            alignment: Alignment.topCenter,
            child: Text(
              "$hour:00",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      children: List.generate((_endHour - _startHour) + 1, (index) {
        return Container(
          height: 60.h,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
        );
      }),
    );
  }

  List<Widget> _buildEntryCards(BuildContext context) {
    final List<Widget> widgets = [];
    final double dayWidth = (MediaQuery.of(context).size.width - 50.w - 40.w) / 5; // 40.w for padding

    for (var entry in entries) {
      final dayIndex = _days.indexOf(entry.day.trim());
      if (dayIndex == -1) continue;

      final startParts = entry.startTime.split(':');
      final endParts = entry.endTime.split(':');
      if (startParts.length < 2 || endParts.length < 2) continue;

      final startH = int.tryParse(startParts[0]) ?? _startHour;
      final startM = int.tryParse(startParts[1]) ?? 0;
      final endH = int.tryParse(endParts[0]) ?? (_startHour + 1);
      final endM = int.tryParse(endParts[1]) ?? 0;

      final topOffset = ((startH - _startHour) * 60.h) + ((startM / 60) * 60.h);
      final durationMinutes = ((endH * 60 + endM) - (startH * 60 + startM));
      final height = (durationMinutes / 60) * 60.h;

      final isLab = entry.sectionName.toLowerCase().contains("عملي") ||
          entry.sectionName.toLowerCase().contains("lab");

      widgets.add(
        Positioned(
          top: topOffset,
          left: (4 - dayIndex) * dayWidth, // RTL layout
          width: dayWidth,
          height: height,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isLab ? const Color(0xFFF5F3FF) : const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: isLab ? const Color(0xFF7C3AED).withAlpha(76) : const Color(0xFF0369A1).withAlpha(76),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.courseCode,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: isLab ? const Color(0xFF7C3AED) : const Color(0xFF0369A1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Text(
                    entry.sectionName.isNotEmpty ? entry.sectionName : "محاضرة",
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
