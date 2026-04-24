class CourseModel {
  final String code;
  final String name;
  final int creditHours;
  final String grade;
  final double degree;

  CourseModel({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.grade,
    required this.degree,

  });

  factory CourseModel.fromApi(Map<String, dynamic> json) {
    return CourseModel(
      code: (json['courseCode'] ?? '').toString(),
      name: (json['courseTitle'] ?? '').toString(),
      creditHours: (json['creditHours'] as num?)?.toInt() ?? 0,
      grade: (json['grade'] ?? '').toString(),
      degree: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SemesterModel {
  final String semesterName;
  final double gpa;
  final List<CourseModel> courses;

  SemesterModel({
    required this.semesterName,
    required this.gpa,
    required this.courses,
  });

  factory SemesterModel.fromApi(Map<String, dynamic> json) {
    return SemesterModel(
      semesterName: (json['semesterName'] ?? '').toString(),
      gpa: (json['semesterGPA'] as num?)?.toDouble() ?? 0,
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => CourseModel.fromApi(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
