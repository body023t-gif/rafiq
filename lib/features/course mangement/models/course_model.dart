import 'package:rafiq/core/utils/json_helpers.dart';

class CourseSectionModel {
  final String id;
  final String sectionName;
  final String instructorName;
  final String scheduleTime;
  final int availableSeats;
  final int totalSeats;

  const CourseSectionModel({
    required this.id,
    required this.sectionName,
    required this.instructorName,
    required this.scheduleTime,
    required this.availableSeats,
    required this.totalSeats,
  });

  bool get isFull => totalSeats > 0 && availableSeats <= 0;

  String get seatsLabel {
    if (isFull) return '0/$totalSeats مكتمل';
    return '$availableSeats/$totalSeats مقعدا';
  }

  factory CourseSectionModel.fromJson(Map<String, dynamic> json) {
    final total = readInt(json, ['totalSeats', 'capacity', 'maxSeats']);
    final available = readInt(json, ['availableSeats', 'remainingSeats', 'seatsAvailable'], total);

    return CourseSectionModel(
      id: readString(json, ['id', 'sectionId']),
      sectionName: readString(json, ['sectionName', 'name', 'sectionCode'], 'Section'),
      instructorName: readString(json, ['instructorName', 'taName', 'doctorName'], '—'),
      scheduleTime: readString(json, ['scheduleTime', 'time', 'schedule'], '—'),
      availableSeats: available,
      totalSeats: total,
    );
  }
}

class CourseItemModel {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String requirementType;
  final String prerequisite;
  final String instructorName;
  final int creditHours;
  final String scheduleTime;
  final int availableSeats;
  final int totalSeats;
  final bool isRecommended;
  final List<CourseSectionModel> sections;

  const CourseItemModel({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.requirementType,
    required this.prerequisite,
    required this.instructorName,
    required this.creditHours,
    required this.scheduleTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.isRecommended,
    required this.sections,
  });

  String get seatsLabel => '$availableSeats/$totalSeats مقعدا';

  factory CourseItemModel.fromJson(Map<String, dynamic> json) {
    final total = readInt(json, ['totalSeats', 'capacity', 'maxSeats'], 30);
    final available = readInt(json, ['availableSeats', 'remainingSeats', 'seatsAvailable'], total);

    return CourseItemModel(
      id: readString(json, ['id', 'courseId']),
      courseCode: readString(json, ['courseCode', 'code']),
      courseTitle: readString(json, ['courseTitle', 'title', 'name']),
      requirementType: readString(json, ['requirementType', 'courseType', 'type'], 'متطلب'),
      prerequisite: readString(json, ['prerequisite', 'previousRequirement', 'preRequisite']),
      instructorName: readString(json, ['instructorName', 'doctorName', 'instructor'], '—'),
      creditHours: readInt(json, ['creditHours', 'credits', 'hours']),
      scheduleTime: readString(json, ['scheduleTime', 'schedule', 'timeSlot']),
      availableSeats: available,
      totalSeats: total,
      isRecommended: readBool(json, ['isRecommended', 'recommended']),
      sections: readMapList(json, ['sections', 'courseSections'])
          .map(CourseSectionModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'requirementType': requirementType,
      'prerequisite': prerequisite,
      'instructorName': instructorName,
      'creditHours': creditHours,
      'scheduleTime': scheduleTime,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'isRecommended': isRecommended,
    };
  }
}

class CoursesPageModel {
  final List<CourseItemModel> courses;
  final int page;
  final int totalPages;
  final int totalCount;

  const CoursesPageModel({
    required this.courses,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  factory CoursesPageModel.fromList(List<Map<String, dynamic>> items) {
    return CoursesPageModel(
      courses: items.map(CourseItemModel.fromJson).toList(),
      page: 1,
      totalPages: 1,
      totalCount: items.length,
    );
  }

  factory CoursesPageModel.fromJson(Map<String, dynamic> json) {
    final items = readMapList(json, ['items', 'courses', 'results']);
    return CoursesPageModel(
      courses: items.map(CourseItemModel.fromJson).toList(),
      page: readInt(json, ['page', 'currentPage'], 1),
      totalPages: readInt(json, ['totalPages', 'pageCount'], 1),
      totalCount: readInt(json, ['totalCount', 'total', 'count'], items.length),
    );
  }
}
