import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';

class SavedTimetableItemModel {
  final String id;
  final String courseName;
  final String type;
  final String? sectionId;
  final String day;
  final String startTime;
  final String endTime;
  final String difficulty;
  final String priority;
  final int capacity;
  final int availableSeats;

  const SavedTimetableItemModel({
    required this.id,
    required this.courseName,
    required this.type,
    this.sectionId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.difficulty,
    required this.priority,
    required this.capacity,
    required this.availableSeats,
  });

  factory SavedTimetableItemModel.fromJson(Map<String, dynamic> json) {
    return SavedTimetableItemModel(
      id: json['id']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      sectionId: json['sectionId']?.toString(),
      day: json['day']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      capacity: json['capacity'] as int? ?? 0,
      availableSeats: json['availableSeats'] as int? ?? 0,
    );
  }

  ScheduleEntryModel toScheduleEntry() {
    return ScheduleEntryModel(
      id: id,
      courseCode: courseName, // We map courseName to both code and title based on instructions
      courseTitle: courseName,
      sectionName: type,
      instructorName: 'â€”', 
      day: day,
      startTime: startTime,
      endTime: endTime,
      creditHours: 0,
      courseId: null,
      lectureGroupId: sectionId,
    );
  }
}

class SavedTimetableModel {
  final String id;
  final String studentId;
  final String timetableName;
  final String optionName;
  final int maxLoad;
  final int totalDays;
  final List<SavedTimetableItemModel> items;

  const SavedTimetableModel({
    required this.id,
    required this.studentId,
    required this.timetableName,
    required this.optionName,
    required this.maxLoad,
    required this.totalDays,
    required this.items,
  });

  factory SavedTimetableModel.fromJson(Map<String, dynamic> json) {
    return SavedTimetableModel(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      timetableName: json['timetableName']?.toString() ?? '',
      optionName: json['optionName']?.toString() ?? '',
      maxLoad: json['maxLoad'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SavedTimetableItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  StudentScheduleModel toStudentScheduleModel() {
    final entries = items.map((item) => item.toScheduleEntry()).toList();
    return StudentScheduleModel(
      totalHours: 0,
      registeredCoursesCount: entries.length,
      entries: entries,
    );
  }
}
