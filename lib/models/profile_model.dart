class StudentProfileModel {
  final String fullName;
  final String universityCode;
  final String departmentName;
  final String profilePictureUrl;
  final double currentGpa;
  final double cumulativeGpa;
  final int level;
  final int completedHours;
  final int totalHours;
  final String academicAdvisorName;
  final List<AcademicSemesterModel> academicHistory;

  const StudentProfileModel({
    required this.fullName,
    required this.universityCode,
    required this.departmentName,
    required this.profilePictureUrl,
    required this.currentGpa,
    required this.cumulativeGpa,
    required this.level,
    required this.completedHours,
    required this.totalHours,
    required this.academicAdvisorName,
    required this.academicHistory,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      fullName: (json['fullName'] ?? '').toString(),
      universityCode: (json['universityCode'] ?? '').toString(),
      departmentName: (json['departmentName'] ?? '').toString(),
      profilePictureUrl: (json['profilePictureUrl'] ?? '').toString(),
      currentGpa: _toDouble(json['currentGPA']),
      cumulativeGpa: _toDouble(json['cumulativeGPA']),
      level: _toInt(json['level']),
      completedHours: _toInt(json['completedHours']),
      totalHours: _toInt(json['totalHours']),
      academicAdvisorName: (json['academicAdvisorName'] ?? '').toString(),
      academicHistory: (json['academicHistory'] as List<dynamic>? ?? [])
          .map((e) => AcademicSemesterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'universityCode': universityCode,
      'departmentName': departmentName,
      'profilePictureUrl': profilePictureUrl,
      'currentGPA': currentGpa,
      'cumulativeGPA': cumulativeGpa,
      'level': level,
      'completedHours': completedHours,
      'totalHours': totalHours,
      'academicAdvisorName': academicAdvisorName,
      'academicHistory': academicHistory.map((e) => e.toJson()).toList(),
    };
  }
}

class AcademicSemesterModel {
  final String semesterName;
  final double semesterGpa;
  final List<AcademicCourseModel> courses;

  const AcademicSemesterModel({
    required this.semesterName,
    required this.semesterGpa,
    required this.courses,
  });

  factory AcademicSemesterModel.fromJson(Map<String, dynamic> json) {
    return AcademicSemesterModel(
      semesterName: (json['semesterName'] ?? '').toString(),
      semesterGpa: _toDouble(json['semesterGPA']),
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => AcademicCourseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semesterName': semesterName,
      'semesterGPA': semesterGpa,
      'courses': courses.map((e) => e.toJson()).toList(),
    };
  }
}

class AcademicCourseModel {
  final String courseCode;
  final String courseTitle;
  final int creditHours;
  final String grade;
  final double score;

  const AcademicCourseModel({
    required this.courseCode,
    required this.courseTitle,
    required this.creditHours,
    required this.grade,
    required this.score,
  });

  factory AcademicCourseModel.fromJson(Map<String, dynamic> json) {
    return AcademicCourseModel(
      courseCode: (json['courseCode'] ?? '').toString(),
      courseTitle: (json['courseTitle'] ?? '').toString(),
      creditHours: _toInt(json['creditHours']),
      grade: (json['grade'] ?? '').toString(),
      score: _toDouble(json['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'creditHours': creditHours,
      'grade': grade,
      'score': score,
    };
  }
}

double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
int _toInt(dynamic value) => (value as num?)?.toInt() ?? 0;
