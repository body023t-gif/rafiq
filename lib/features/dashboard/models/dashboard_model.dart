import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardModel {
  final String firstName;
  final double cgpa;
  final int earnedHours;
  final List<GpaProgressModel> gpaProgress;
  final PlanProgressModel planProgress;

  const DashboardModel({
    required this.firstName,
    required this.cgpa,
    required this.earnedHours,
    required this.gpaProgress,
    required this.planProgress,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      firstName: (json['firstName'] ?? '').toString(),
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0,
      earnedHours: (json['earnedHours'] as num?)?.toInt() ?? 0,
      gpaProgress: (json['gpaProgress'] as List<dynamic>? ?? [])
          .map((e) => GpaProgressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      planProgress: PlanProgressModel.fromJson(
        (json['planProgress'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'cgpa': cgpa,
      'earnedHours': earnedHours,
      'gpaProgress': gpaProgress.map((e) => e.toJson()).toList(),
      'planProgress': planProgress.toJson(),
    };
  }

  List<BarChartGroupData> get gpaChartBars {
    return gpaProgress
        .asMap()
        .entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.gpa,
                width: 34,
                color: const Color(0xFF2F63BF),
              ),
            ],
          ),
        )
        .toList();
  }
}

class GpaProgressModel {
  final String termName;
  final double gpa;

  const GpaProgressModel({
    required this.termName,
    required this.gpa,
  });

  factory GpaProgressModel.fromJson(Map<String, dynamic> json) {
    return GpaProgressModel(
      termName: (json['termName'] ?? '').toString(),
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termName': termName,
      'gpa': gpa,
    };
  }
}

class PlanProgressModel {
  final int completedCourses;
  final int remainingCourses;
  final double universityRequirementsPercentage;
  final double majorRequirementsPercentage;
  final double electiveRequirementsPercentage;

  const PlanProgressModel({
    required this.completedCourses,
    required this.remainingCourses,
    required this.universityRequirementsPercentage,
    required this.majorRequirementsPercentage,
    required this.electiveRequirementsPercentage,
  });

  factory PlanProgressModel.fromJson(Map<String, dynamic> json) {
    return PlanProgressModel(
      completedCourses: (json['completedCourses'] as num?)?.toInt() ?? 0,
      remainingCourses: (json['remainingCourses'] as num?)?.toInt() ?? 0,
      universityRequirementsPercentage: _toPercent(
        (json['universityRequirementsPercentage'] as num?)?.toDouble() ?? 0,
      ),
      majorRequirementsPercentage: _toPercent(
        (json['majorRequirementsPercentage'] as num?)?.toDouble() ?? 0,
      ),
      electiveRequirementsPercentage: _toPercent(
        (json['electiveRequirementsPercentage'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedCourses': completedCourses,
      'remainingCourses': remainingCourses,
      'universityRequirementsPercentage': universityRequirementsPercentage,
      'majorRequirementsPercentage': majorRequirementsPercentage,
      'electiveRequirementsPercentage': electiveRequirementsPercentage,
    };
  }
}

double _toPercent(double value) => value > 1 ? value / 100 : value;
