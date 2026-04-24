class ProfileModel {
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
  final List<AcademicHistoryModel> academicHistory;

  const ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: (json['fullName'] ?? '').toString(),
      universityCode: (json['universityCode'] ?? '').toString(),
      departmentName: (json['departmentName'] ?? '').toString(),
      profilePictureUrl: (json['profilePictureUrl'] ?? '').toString(),
      currentGpa: (json['currentGPA'] as num?)?.toDouble() ?? 0,
      cumulativeGpa: (json['cumulativeGPA'] as num?)?.toDouble() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      completedHours: (json['completedHours'] as num?)?.toInt() ?? 0,
      totalHours: (json['totalHours'] as num?)?.toInt() ?? 0,
      academicAdvisorName: (json['academicAdvisorName'] ?? '').toString(),
      academicHistory: (json['academicHistory'] as List<dynamic>? ?? [])
          .map((e) => AcademicHistoryModel.fromJson(e as Map<String, dynamic>))
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

class AcademicHistoryModel {
  final String semesterName;
  final double semesterGpa;
  final List<CourseModel> courses;

  const AcademicHistoryModel({
    required this.semesterName,
    required this.semesterGpa,
    required this.courses,
  });

  factory AcademicHistoryModel.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryModel(
      semesterName: (json['semesterName'] ?? '').toString(),
      semesterGpa: (json['semesterGPA'] as num?)?.toDouble() ?? 0,
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
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

class CourseModel {
  final String courseCode;
  final String courseTitle;
  final int creditHours;
  final String grade;
  final double score;

  const CourseModel({
    required this.courseCode,
    required this.courseTitle,
    required this.creditHours,
    required this.grade,
    required this.score,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseCode: (json['courseCode'] ?? '').toString(),
      courseTitle: (json['courseTitle'] ?? '').toString(),
      creditHours: (json['creditHours'] as num?)?.toInt() ?? 0,
      grade: (json['grade'] ?? '').toString(),
      score: (json['score'] as num?)?.toDouble() ?? 0,
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
