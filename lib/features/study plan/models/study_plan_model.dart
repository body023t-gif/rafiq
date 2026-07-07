import 'package:rafiq/core/utils/json_helpers.dart';

class StudyPlanCourseModel {
  final String courseCode;
  final String courseTitle;
  final int creditHours;
  final String status;
  final String semesterName;
  final String confidence;
  final String score;

  const StudyPlanCourseModel({
    required this.courseCode,
    required this.courseTitle,
    required this.creditHours,
    required this.status,
    required this.semesterName,
    this.confidence = '',
    this.score = '',
  });

  factory StudyPlanCourseModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanCourseModel(
      courseCode: readString(json, ['courseCode', 'code']),
      courseTitle: readString(json, ['courseTitle', 'title', 'name']),
      creditHours: readInt(json, ['creditHours', 'credits', 'hours']),
      status: readString(json, ['status', 'courseStatus']),
      semesterName: readString(json, ['semesterName', 'semester', 'term']),
      confidence: readString(json, ['confidence', 'Confidence']),
      score: readString(json, ['score', 'Score']),
    );
  }
}

class StudyPlanSemesterModel {
  final String semesterName;
  final List<StudyPlanCourseModel> courses;

  const StudyPlanSemesterModel({
    required this.semesterName,
    required this.courses,
  });

  factory StudyPlanSemesterModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanSemesterModel(
      semesterName: readString(json, ['semesterName', 'semester', 'name'], 'فصل'),
      courses: readMapList(json, ['courses', 'items'])
          .map(StudyPlanCourseModel.fromJson)
          .toList(),
    );
  }
}

class StudyPlanModel {
  final String studentId;
  final int completedHours;
  final int remainingHours;
  final int totalHours;
  final List<StudyPlanSemesterModel> semesters;
  final List<StudyPlanCourseModel> courses;

  const StudyPlanModel({
    required this.studentId,
    required this.completedHours,
    required this.remainingHours,
    required this.totalHours,
    required this.semesters,
    required this.courses,
  });

  bool get isEmpty => semesters.isEmpty && courses.isEmpty;

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    // TODO(Backend): Replace this temporary mapping with the dedicated Study Plan Improvement endpoint when it becomes available.
    
    // Parse the recommendations array if available, fallback to courses/items
    final recommendationsRaw = json['recommendations'];
    List<StudyPlanCourseModel> flatCourses = [];
    
    if (recommendationsRaw is List) {
      flatCourses = recommendationsRaw.map((e) {
        if (e is String) {
          return StudyPlanCourseModel(
            courseCode: '',
            courseTitle: e,
            creditHours: 0,
            status: '',
            semesterName: '',
          );
        } else if (e is Map<String, dynamic>) {
          return StudyPlanCourseModel.fromJson(e);
        }
        return const StudyPlanCourseModel(
          courseCode: '',
          courseTitle: 'Unknown',
          creditHours: 0,
          status: '',
          semesterName: '',
        );
      }).toList();
    } else {
      flatCourses = readMapList(json, ['courses', 'planCourses', 'items'])
          .map(StudyPlanCourseModel.fromJson)
          .toList();
    }

    final semesters = readMapList(json, ['semesters', 'terms', 'planSemesters'])
        .map(StudyPlanSemesterModel.fromJson)
        .toList();

    return StudyPlanModel(
      studentId: readString(json, ['studentId', 'id']),
      completedHours: readInt(json, ['completedHours', 'earnedHours']),
      remainingHours: readInt(json, ['remainingHours', 'leftHours']),
      totalHours: readInt(json, ['totalHours', 'requiredHours']),
      semesters: semesters,
      courses: flatCourses,
    );
  }
}
