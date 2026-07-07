import 'dart:math';

class StudentProgressModel {
  final double gpa;
  final double cumulativeGpa;
  final String level;
  final int completedHours;
  final int remainingHours;
  final String advisorName;

  StudentProgressModel({
    required this.gpa,
    required this.cumulativeGpa,
    required this.level,
    required this.completedHours,
    required this.remainingHours,
    required this.advisorName,
  });

  factory StudentProgressModel.fromProfile({
    required double currentGpa,
    required double cumulativeGpa,
    required int level,
    required int completedHours,
    required int totalHours,
    required String advisorName,
  }) {
    return StudentProgressModel(
      gpa: currentGpa,
      cumulativeGpa: cumulativeGpa,
      level: "المستوى $level",
      completedHours: completedHours,
      remainingHours: max(0, totalHours - completedHours),
      advisorName: advisorName,
    );
  }
}
