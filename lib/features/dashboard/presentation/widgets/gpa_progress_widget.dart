import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rafiq/features/dashboard/models/dashboard_model.dart';

class GPAProgress extends StatelessWidget {
  final List<GpaProgressModel> progressPoints;

  const GPAProgress({
    super.key,
    required this.progressPoints,
  });

  @override
  Widget build(BuildContext context) {
    final chartData = progressPoints.isEmpty
        ? const [
            GpaProgressModel(termName: 'N/A', gpa: 0),
          ]
        : progressPoints;
    final maxGpa = chartData
        .map((e) => e.gpa)
        .fold<double>(4.0, (current, value) => value > current ? value : current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: Color(0xff1564BF),
            ),
            const SizedBox(width: 2),
            Text(
              "تقدم المعدل",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        Container(
          width: 380.w,
          height: 300.h,
          padding: EdgeInsets.only(
            top: 38.h,
            bottom: 18.h,
            left: 16.w,
            right: 16.w,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE3E4E8),
              width: 1.w,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          //
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxGpa + 0.5,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),

              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.length) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        chartData[index].gpa.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          chartData[index].termName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: index == chartData.length - 1
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              barGroups: [
                for (var i = 0; i < chartData.length; i++)
                  _buildBar(i, chartData[i].gpa),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 34.w,
          borderRadius: BorderRadius.circular(14.r),
          color: const Color(0xFF2F63BF),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 4.2,
            color: const Color(0xFFE9D6D9),
          ),
        ),
      ],
    );
  }
}