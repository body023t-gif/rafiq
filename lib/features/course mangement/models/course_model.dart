import 'package:rafiq/core/utils/json_helpers.dart';
import 'dart:developer';

class CourseSectionModel {
  final String id;
  final String sectionId;
  final String sectionName;
  final String instructorName;
  final String scheduleTime;
  final String location;
  final int availableSeats;
  final int totalSeats;
  final int registeredStudents;

  const CourseSectionModel({
    required this.id,
    required this.sectionId,
    required this.sectionName,
    required this.instructorName,
    required this.scheduleTime,
    required this.location,
    required this.availableSeats,
    required this.totalSeats,
    required this.registeredStudents,
  });

  bool get isFull => totalSeats > 0 && availableSeats <= 0;

  String get seatsLabel {
    if (isFull) return '$totalSeats/$totalSeats مكتمل';
    return '$registeredStudents/$totalSeats مقعدا';
  }

  factory CourseSectionModel.fromJson(Map<String, dynamic> json) {
    final total = readInt(json, ['totalSeats', 'capacity', 'maxSeats']);
    final available = readInt(json, [
      'availableSeats',
      'remainingSeats',
      'seatsAvailable',
    ], total);
    final registered = readInt(json, [
      'registeredStudents',
      'enrolledStudentsCount',
      'enrolled',
    ], total - available);

    final lgId = readString(json, ['lectureGroupId', 'groupId']);
    final secId = readString(json, ['sectionId', 'id']);
    final idStr = lgId.isNotEmpty ? lgId : secId;
    final sectionIdStr = secId.isNotEmpty ? secId : idStr;

    // Parse location
    String building = readString(json, ['building', 'buildingName']);
    String room = readString(json, ['room', 'roomNumber', 'hall', 'hallName']);
    String floor = readString(json, ['floor']);
    String loc = [building, floor, room].where((e) => e.isNotEmpty).join(' - ');
    if (loc.isEmpty) {
      loc = readString(json, ['location'], '—');
    }

    // Parse scheduleTime
    String schedTime = readString(json, ['scheduleTime', 'time', 'schedule']);
    if (schedTime.isEmpty) {
      final dayMap = {
        0: 'الأحد',
        1: 'الإثنين',
        2: 'الثلاثاء',
        3: 'الأربعاء',
        4: 'الخميس',
        5: 'الجمعة',
        6: 'السبت',
      };
      
      String dayStr = readString(json, ['dayName', 'dayString']);
      if (dayStr.isEmpty && json['day'] is int) {
        dayStr = dayMap[json['day'] as int] ?? '';
      } else if (dayStr.isEmpty && json['day'] is String) {
        dayStr = json['day'].toString();
      }
      
      String sTime = readString(json, ['startTime']);
      if (sTime.length >= 5) {
        sTime = sTime.substring(0, 5); // Keep HH:mm
      }
      String eTime = readString(json, ['endTime']);
      if (eTime.isEmpty && json['duration'] is int && sTime.isNotEmpty) {
        try {
          final parts = sTime.split(':');
          if (parts.length >= 2) {
            final hr = int.parse(parts[0]) + (json['duration'] as int);
            eTime = '${hr.toString().padLeft(2, '0')}:${parts[1]}';
          }
        } catch (_) {}
      } else if (eTime.length >= 5) {
        eTime = eTime.substring(0, 5);
      }
      
      if (dayStr.isNotEmpty && sTime.isNotEmpty) {
        schedTime = '$dayStr, $sTime${eTime.isNotEmpty ? ' - $eTime' : ''}';
      } else if (sTime.isNotEmpty) {
        schedTime = '$sTime${eTime.isNotEmpty ? ' - $eTime' : ''}';
      }
      if (schedTime.isEmpty) schedTime = '';
    }

    return CourseSectionModel(
      id: idStr,
      sectionId: sectionIdStr,
      sectionName: readString(json, [
        'sectionName',
        'name',
        'sectionCode',
      ], 'Section'),
      instructorName: readString(json, [
        'instructorName',
        'taName',
        'doctorName',
        'lecturerName',
        'staffName',
      ], '—'),
      scheduleTime: schedTime,
      location: loc,
      availableSeats: available,
      totalSeats: total,
      registeredStudents: registered,
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
  final int registeredStudents;
  final bool isRecommended;
  final List<CourseSectionModel> sections;
  final List<LectureGroupModel> lectureGroups;

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
    required this.registeredStudents,
    required this.isRecommended,
    required this.sections,
    required this.lectureGroups,
  });

  String get seatsLabel => '$registeredStudents/$totalSeats مقعدا';

  factory CourseItemModel.fromJson(Map<String, dynamic> json) {
    final total = readInt(json, ['totalSeats', 'capacity', 'maxSeats'], 30);
    final available = readInt(json, [
      'availableSeats',
      'remainingSeats',
      'seatsAvailable',
    ], total);
    final registered = readInt(json, [
      'registeredStudents',
      'enrolledStudentsCount',
      'enrolled',
    ], total - available);

    // Debug logs
    assert(() {
      log('--- Course Debug ---');
      log('Course: ${readString(json, ['courseTitle', 'title', 'name'])}');
      log('Capacity: $total');
      log('Available Seats: $available');
      log('Registered Students: $registered');
      log('Displayed Text: $registered/$total مقعدا');
      log('--------------------');
      return true;
    }());

    return CourseItemModel(
      id: readString(json, ['id', 'courseId']),
      courseCode: readString(json, ['courseCode', 'code']),
      courseTitle: readString(json, ['courseTitle', 'title', 'name']),
      requirementType: readString(json, [
        'requirementType',
        'courseType',
        'type',
      ], 'متطلب'),
      prerequisite: readString(json, [
        'prerequisite',
        'previousRequirement',
        'preRequisite',
      ]),
      instructorName: readString(json, [
        'instructorName',
        'doctorName',
        'instructor',
      ], '—'),
      creditHours: readInt(json, ['creditHours', 'credits', 'hours']),
      scheduleTime: readString(json, ['scheduleTime', 'schedule', 'timeSlot']),
      availableSeats: available,
      totalSeats: total,
      registeredStudents: registered,
      isRecommended: readBool(json, ['isRecommended', 'recommended']),
      sections: readMapList(json, [
        'sections',
        'courseSections',
      ]).map(CourseSectionModel.fromJson).toList(),
      lectureGroups: readMapList(json, [
        'lectureGroups',
      ]).map(LectureGroupModel.fromJson).toList(),
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

class LectureGroupModel {
  final String id;
  final String doctorName;
  final String day;
  final String time;
  final int capacity;
  final int enrolledStudentsCount;
  final String location;

  const LectureGroupModel({
    required this.id,
    required this.doctorName,
    required this.day,
    required this.time,
    required this.capacity,
    required this.enrolledStudentsCount,
    required this.location,
  });

  int get availableSeats => capacity > enrolledStudentsCount ? capacity - enrolledStudentsCount : 0;
  bool get isFull => capacity > 0 && availableSeats <= 0;

  String get seatsLabel {
    if (isFull) return '$capacity/$capacity مكتمل';
    return '$enrolledStudentsCount/$capacity مقعدا';
  }

  factory LectureGroupModel.fromJson(Map<String, dynamic> json) {
    final total = readInt(json, ['capacity', 'totalSeats', 'maxSeats'], 30);
    final registered = readInt(json, ['enrolledStudentsCount', 'registeredStudents', 'enrolled'], 0);
    
    return LectureGroupModel(
      id: readString(json, ['id', 'lectureGroupId']),
      doctorName: readString(json, ['doctorName', 'instructorName', 'instructor'], '—'),
      day: readString(json, ['day', 'scheduleDay'], '—'),
      time: readString(json, ['time', 'scheduleTime'], '—'),
      capacity: total,
      enrolledStudentsCount: registered,
      location: readString(json, ['location', 'room'], '—'),
    );
  }
}
