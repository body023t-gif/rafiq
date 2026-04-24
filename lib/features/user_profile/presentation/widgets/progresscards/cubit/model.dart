class StudentProgressModel {
  final double gpa;
  final String level;
  final int completedHours;
  final int remainingHours;
  final String advisorName;

  StudentProgressModel({
    required this.gpa,
    required this.level,
    required this.completedHours,
    required this.remainingHours,
    required this.advisorName,
  });

  factory StudentProgressModel.fromProfile({
    required double currentGpa,
    required int level,
    required int completedHours,
    required int totalHours,
    required String advisorName,
  }) {
    return StudentProgressModel(
      gpa: currentGpa,
      level: "المستوى $level",
      completedHours: completedHours,
      remainingHours: (totalHours - completedHours).clamp(0, totalHours),
      advisorName: advisorName,
    );
  }
}
