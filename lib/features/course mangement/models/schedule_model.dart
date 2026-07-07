import 'package:rafiq/core/utils/json_helpers.dart';

class ScheduleEntryModel {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String sectionName;
  final String instructorName;
  final String day;
  final String startTime;
  final String endTime;
  final int creditHours;
  final String? courseId;
  final String? lectureGroupId;

  const ScheduleEntryModel({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.sectionName,
    required this.instructorName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.creditHours,
    this.courseId,
    this.lectureGroupId,
  });

  String get timeLabel {
    if (startTime.isEmpty && endTime.isEmpty) return '—';
    if (endTime.isEmpty) return startTime;
    return '$startTime - $endTime';
  }

  String get scheduleLabel {
    if (day.isEmpty) return timeLabel;
    return '$day • $timeLabel';
  }

  factory ScheduleEntryModel.fromJson(Map<String, dynamic> json) {
    return ScheduleEntryModel(
      id: readString(json, ['id', 'scheduleId', 'entryId']),
      courseCode: readString(json, ['courseCode', 'code']),
      courseTitle: readString(json, ['courseTitle', 'title', 'name']),
      sectionName: readString(json, ['sectionName', 'section', 'sectionCode']),
      instructorName: readString(json, ['instructorName', 'doctorName', 'taName'], '—'),
      day: readString(json, ['day', 'dayName', 'weekDay']),
      startTime: readString(json, ['startTime', 'fromTime', 'timeFrom']),
      endTime: readString(json, ['endTime', 'toTime', 'timeTo']),
      creditHours: readInt(json, ['creditHours', 'credits', 'hours']),
      courseId: readString(json, ['courseId']),
      lectureGroupId: readString(json, ['lectureGroupId']),
    );
  }
}

class StudentScheduleModel {
  final int totalHours;
  final int registeredCoursesCount;
  final List<ScheduleEntryModel> entries;

  const StudentScheduleModel({
    required this.totalHours,
    required this.registeredCoursesCount,
    required this.entries,
  });

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) {
    final entries = readMapList(json, ['entries', 'schedule', 'items', 'courses'])
        .map(ScheduleEntryModel.fromJson)
        .toList();

    return StudentScheduleModel(
      totalHours: readInt(json, ['totalHours', 'totalCreditHours', 'hours'], _sumHours(entries)),
      registeredCoursesCount: readInt(
        json,
        ['registeredCoursesCount', 'coursesCount', 'totalCourses'],
        entries.length,
      ),
      entries: entries,
    );
  }

  static int _sumHours(List<ScheduleEntryModel> entries) {
    return entries.fold(0, (sum, entry) => sum + entry.creditHours);
  }
}
