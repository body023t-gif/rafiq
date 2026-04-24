class StudentDashboardModel {
  final String firstName;
  final double cgpa;
  final int earnedHours;
  final List<GpaProgressPointModel> gpaProgress;
  final PlanProgressModel planProgress;

  const StudentDashboardModel({
    required this.firstName,
    required this.cgpa,
    required this.earnedHours,
    required this.gpaProgress,
    required this.planProgress,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      firstName: (json['firstName'] ?? '').toString(),
      cgpa: _toDouble(json['cgpa']),
      earnedHours: _toInt(json['earnedHours']),
      gpaProgress: (json['gpaProgress'] as List<dynamic>? ?? [])
          .map((e) => GpaProgressPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      planProgress: PlanProgressModel.fromJson(
        (json['planProgress'] as Map<String, dynamic>?) ?? <String, dynamic>{},
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
}

class GpaProgressPointModel {
  final String termName;
  final double gpa;

  const GpaProgressPointModel({
    required this.termName,
    required this.gpa,
  });

  factory GpaProgressPointModel.fromJson(Map<String, dynamic> json) {
    return GpaProgressPointModel(
      termName: (json['termName'] ?? '').toString(),
      gpa: _toDouble(json['gpa']),
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
      completedCourses: _toInt(json['completedCourses']),
      remainingCourses: _toInt(json['remainingCourses']),
      universityRequirementsPercentage: _toPercent(
        json['universityRequirementsPercentage'],
      ),
      majorRequirementsPercentage: _toPercent(
        json['majorRequirementsPercentage'],
      ),
      electiveRequirementsPercentage: _toPercent(
        json['electiveRequirementsPercentage'],
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

double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
int _toInt(dynamic value) => (value as num?)?.toInt() ?? 0;
double _toPercent(dynamic value) {
  final parsed = (value as num?)?.toDouble() ?? 0.0;
  return parsed > 1 ? parsed / 100 : parsed;
}
