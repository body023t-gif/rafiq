import 'package:rafiq/core/utils/json_helpers.dart';
import 'dart:developer';

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
  final String location;
  final String status;
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
    this.location = '',
    this.status = '',
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
    // Add debug logs for parsing
    assert(() {
      log('\n================================');
      log('DEBUG: ScheduleEntryModel Parsing');
      log(
        'Course: ${json['courseCode'] ?? json['code']} / ${json['courseTitle'] ?? json['title']}',
      );
      log('Raw JSON: $json');
      return true;
    }());

    // Extract fields with expanded fallback names, and handle possible nested objects
    String parsedInstructor = readString(json, [
      'instructorName',
      'doctorName',
      'taName',
      'instructor',
      'lecturer',
      'lecturerName',
      'teacher',
      'staffName',
    ]);

    // If the backend returns a nested object (e.g. "instructor": {"name": "Dr. Ahmed"}), extract it.
    if (parsedInstructor.isEmpty) {
      final instructorObj = json['instructor'] ?? json['lecturer'];
      if (instructorObj is Map<String, dynamic>) {
        parsedInstructor =
            instructorObj['name'] ?? instructorObj['instructorName'] ?? '';
      }
    }

    final parsedHours = readInt(json, [
      'creditHours',
      'credits',
      'hours',
      'courseHours',
    ]);

    assert(() {
      log('Parsed Instructor: $parsedInstructor');
      log('Parsed Credit Hours: $parsedHours');
      log('================================\n');
      return true;
    }());

    return ScheduleEntryModel(
      id: readString(json, ['id', 'scheduleId', 'entryId', 'section_id']),
      courseCode: readString(json, ['courseCode', 'code', 'course']),
      courseTitle: readString(json, ['courseTitle', 'title', 'name', 'course']),
      sectionName: readString(json, [
        'sectionName',
        'section',
        'sectionCode',
        'type',
      ]),
      instructorName: parsedInstructor,
      day: readString(json, ['day', 'dayName', 'weekDay']),
      startTime: readString(json, [
        'time',
        'startTime',
        'fromTime',
        'timeFrom',
        'start_time',
      ]),
      endTime: readString(json, ['endTime', 'toTime', 'timeTo', 'end_time']),
      creditHours: parsedHours,
      location: readString(json, ['location', 'hall', 'room', 'building']),
      status: readString(json, ['status', 'state']),
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
    final entries = readMapList(json, [
      'entries',
      'schedule',
      'items',
      'courses',
    ]).map(ScheduleEntryModel.fromJson).toList();

    return StudentScheduleModel(
      totalHours: readInt(json, [
        'totalHours',
        'totalCreditHours',
        'hours',
      ], _sumHours(entries)),
      registeredCoursesCount: readInt(json, [
        'registeredCoursesCount',
        'coursesCount',
        'totalCourses',
      ], entries.length),
      entries: entries,
    );
  }

  static int _sumHours(List<ScheduleEntryModel> entries) {
    return entries.fold(0, (sum, entry) => sum + entry.creditHours);
  }
}
