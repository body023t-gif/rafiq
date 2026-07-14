import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';
import 'package:rafiq/features/course%20mangement/models/saved_timetable_model.dart';

class TimetableRepository {
  final TimetableRemoteDataSource remoteDataSource;

  const TimetableRepository(this.remoteDataSource);

  void log(String message) {
    ApiService.log(message);
  }

  void logJwtAndUserInformation() {
    final token = ApiService.dynamicToken ?? ApiService.staticToken;
    log('========== [Runtime User Information] ==========');
    if (token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decodedBytes = base64Url.decode(normalized);
          final decodedString = utf8.decode(decodedBytes);
          final Map<String, dynamic> claims = json.decode(decodedString);

          final email = claims['email'] ?? claims['unique_name'] ?? 'Unknown';
          final role =
              claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
              claims['role'] ??
              'Unknown';
          final expUnix = claims['exp'];
          DateTime? expTime;
          if (expUnix is num) {
            expTime = DateTime.fromMillisecondsSinceEpoch(
              expUnix.toInt() * 1000,
            );
          }

          log('  - Student Email: $email');
          log(
            '  - ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}',
          );
          log('  - ApiService.dynamicUserId: ${ApiService.dynamicUserId}');
          log('  - JWT Role: $role');
          log('  - JWT Expiration: $expTime');
        } else {
          log('  - Token format invalid (fewer than 2 parts)');
        }
      } catch (e) {
        log('  - Error decoding JWT: $e');
      }
    } else {
      log('  - No Authorization Token active!');
    }
    log('================================================');
  }

  Future<TimetableModel> generateTimetable(
    TimetableRequestModel request,
  ) async {
    logJwtAndUserInformation();
    log('========== [Generate Timetable Repository Call] ==========');
    log('  - Selected Course IDs: ${request.courseIds}');
    log('  - Selected Strategy: ${request.strategy.apiValue}');
    log('  - Number of Selected Courses: ${request.courseIds.length}');

    try {
      final Map<String, dynamic> coursesMap = {};
      final List<String> courseCodes = [];

      int parseDay(String dayStr) {
        final original = dayStr.trim();
        final normalized = original
            .replaceAll('إ', 'ا')
            .replaceAll('أ', 'ا')
            .replaceAll('آ', 'ا');

        int mapped = 0;
        switch (normalized) {
          case 'الاحد':
            mapped = 0;
            break;
          case 'الاثنين':
            mapped = 1;
            break;
          case 'الثلاثاء':
            mapped = 2;
            break;
          case 'الاربعاء':
            mapped = 3;
            break;
          case 'الخميس':
            mapped = 4;
            break;
          case 'الجمعة':
            mapped = 5;
            break;
          case 'السبت':
            mapped = 6;
            break;
          default:
            mapped = 0;
            break;
        }

        if (kDebugMode) {
          // Temporarily using log as debug logs are required here.
          log('    * parseDay - Original day: $original');
          log('    * parseDay - Normalized day: $normalized');
          log('    * parseDay - Mapped integer: $mapped');
        }

        return mapped;
      }

      Map<String, String> parseTime(String timeRange) {
        final parts = timeRange.split('-');
        if (parts.isEmpty) return {'start': '08:00', 'duration': '120'};
        final startStr = parts.first.trim();
        String startVal = startStr;
        if (startVal.length == 4) startVal = '0$startVal';

        int durationVal = 120;
        if (parts.length > 1) {
          try {
            final endStr = parts[1].trim();
            final startParts = startStr.split(':');
            final endParts = endStr.split(':');
            final startHr = int.parse(startParts[0]);
            final startMin = int.parse(startParts[1]);
            final endHr = int.parse(endParts[0]);
            final endMin = int.parse(endParts[1]);
            durationVal = ((endHr * 60) + endMin) - ((startHr * 60) + startMin);
          } catch (_) {}
        }
        return {'start': startVal, 'duration': durationVal.toString()};
      }

      log('--- Fetching student schedule to identify registered lectureGroups ---');
      Map<String, String> registeredLectureGroups = {};
      try {
        final scheduleRes = await remoteDataSource.getStudentSchedule();
        final scheduleData = scheduleRes['data'] ?? scheduleRes;
        final scheduleEntries = scheduleData['entries'] ?? scheduleData['schedule'] ?? scheduleData['items'] ?? scheduleData['courses'] ?? [];
        for (final entry in scheduleEntries) {
          final cId = entry['courseId'];
          final lgId = entry['lectureGroupId'];
          if (cId != null && lgId != null) {
            registeredLectureGroups[cId.toString()] = lgId.toString();
          }
        }
        log('    * Registered Course ID -> Lecture Group ID mapping: $registeredLectureGroups');
      } catch (e) {
        log('    * Failed to fetch student schedule: $e');
      }

      for (final id in request.courseIds) {
        log('\n--- Processing Course ID: $id ---');
        try {
          final rawDetails = await remoteDataSource.getCourseDetails(id);
          log('[Course Details Raw Response]:');
          log(json.encode(rawDetails));

          final data = rawDetails['data'] ?? rawDetails;
          final courseCode = data['code'] ?? data['courseCode'] ?? 'Unknown';
          final courseTitle = data['title'] ?? data['courseTitle'] ?? 'Unknown';
          courseCodes.add(courseCode.toString());
          log('  - CourseId: $id');
          log('  - CourseCode: $courseCode');
          log('  - CourseTitle: $courseTitle');

          final lectureGroups = data['lectureGroups'];
          final sections = data['sections'];

          final lectureGroupsCount = lectureGroups is List
              ? lectureGroups.length
              : 0;
          final sectionsCount = sections is List ? sections.length : 0;

          log(
            "lectureGroups type: ${lectureGroups?.runtimeType}, count: $lectureGroupsCount",
          );
          if (lectureGroups is List && lectureGroups.isNotEmpty) {
            for (var group in lectureGroups) {
              final capacity = group['capacity'] ?? 50;
              final enrolled = group['enrolledStudentsCount'] ?? 0;
              log('    * LectureGroup ID: ${group['id']}');
              log('      - capacity: $capacity');
              log('      - availableSeats: ${capacity - enrolled}');
              log('      - day: ${group['day']}');
              log('      - time: ${group['time']}');
            }
          }
          log("sections type: ${sections?.runtimeType}, count: $sectionsCount");

          final groups = lectureGroups as List?;
          final rawSections = sections as List?;

          if (groups == null || groups.isEmpty) {
            log(
              "Skipped course $id because no valid lecture groups exist (lectureGroups is null or empty).",
            );
            continue;
          }

          final registeredLgId = registeredLectureGroups[id];
          Map<String, dynamic>? mainLecture;

          if (registeredLgId != null) {
            log('  - Found registered lectureGroupId for course: $registeredLgId');
            try {
              final group = groups.firstWhere((g) => g['id'] == registeredLgId);
              final capacity = group['capacity'] ?? 50;
              final enrolled = group['enrolledStudentsCount'] ?? 0;
              final available = capacity - enrolled;
              final timeMap = parseTime(group['time'].toString());
              
              mainLecture = {
                'id': group['id'],
                'day': parseDay(group['day'].toString()),
                'start': timeMap['start'],
                'duration': int.tryParse(timeMap['duration'] ?? '120') ?? 120,
                'capacity': capacity,
                'available_seats': available,
              };
            } catch (_) {
              log('  - Warning: Registered lectureGroupId not found in course lectureGroups.');
              log('    * courseId: $id');
              log('    * registered lectureGroupId: $registeredLgId');
              log('    * all returned lectureGroup ids: ${groups.map((g) => g['id']).toList()}');
              throw ApiException('Registered lectureGroupId $registeredLgId not found in course $id.');
            }
          } else {
            log('  - Warning: No registered lectureGroupId found in student schedule for course: $id.');
            throw ApiException('No registered lectureGroupId found in student schedule for course: $id.');
          }

          final List<Map<String, dynamic>> finalSections = [];
          if (rawSections != null && rawSections.isNotEmpty) {
            for (final sec in rawSections) {
              final capacity = sec['capacity'] ?? 50;
              final enrolled = sec['enrolledStudentsCount'] ?? 0;
              final available = capacity - enrolled;
              
              if (available > 0 && sec['id'] != mainLecture['id']) {
                int rawDuration = sec['duration'] ?? 1;
                int mappedDuration = rawDuration * 60;

                String rawStart = sec['startTime'] ?? '08:00:00';
                String mappedStart = rawStart;
                if (mappedStart.length >= 5) {
                  mappedStart = mappedStart.substring(0, 5);
                }

                finalSections.add({
                  'id': sec['id'],
                  'day': sec['day'],
                  'start': mappedStart,
                  'duration': mappedDuration,
                  'capacity': capacity,
                  'available_seats': available,
                });
              }
            }
          }

          coursesMap[courseCode] = {
            'priority': 1,
            'difficulty': 1,
            'lecture': mainLecture,
            'sections': finalSections,
          };

          if (kDebugMode) {
            log("Course $courseCode mapping generated:");
            log("  - Registered lectureGroupId: $registeredLgId");
            log("  - Selected lecture id: ${mainLecture['id']}");
            log("  - Section ids: ${finalSections.map((s) => s['id']).toList()}");
            log("  - Final payload part: ${json.encode(coursesMap[courseCode])}");
          }
          log("Successfully added course $courseCode to coursesMap.");
        } catch (e, stackTrace) {
          log("Error fetching details for course $id: $e\n$stackTrace");
          log(
            "Course: $id\nSkipped due to unexpected exception in detail fetch/parse.",
          );
        }
      }

      log('  - Selected Course Codes: $courseCodes');
      log('  - Final Generated Courses Map: $coursesMap');

      final generateBody = {
        'timetableRequest': {
          'option': 'balance',
          'preferences': {'buffer_minutes': 0},
          'courses': coursesMap,
        }
      };

      log('======== Generate Timetable ========');
      log('Request JSON');
      log(json.encode(generateBody));

      final data = await remoteDataSource.generateTimetable(generateBody);

      log('Response JSON');
      log(json.encode(data));
      log('====================================');

      return TimetableModel.fromJson(data);
    } on ApiException catch (e) {
      log("ApiException in generateTimetable: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in generateTimetable: $e");
      throw const ApiException('Failed to generate timetable.');
    }
  }

  Future<TimetableModel> saveTimetable(
    SaveTimetableRequestModel request,
  ) async {
    logJwtAndUserInformation();

    final requestJson = request.toJson();

    if (kDebugMode) {
      log('======== Save Timetable ========');
      log('Request JSON');
      log(json.encode(requestJson));
    }

    try {
      final data = await remoteDataSource.saveTimetable(requestJson);

      if (kDebugMode) {
        log('Response JSON');
        log(json.encode(data));
        log('================================');
      }

      return TimetableModel.fromJson(data);
    } on ApiException catch (e) {
      log("ApiException in saveTimetable: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in saveTimetable: $e");
      throw const ApiException('Failed to save timetable.');
    }
  }

  Future<List<SavedTimetableModel>> getSavedTimetables(String studentId) async {
    try {
      final response = await remoteDataSource.getSavedTimetables(studentId);
      return response.map((e) => SavedTimetableModel.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      log("ApiException in getSavedTimetables: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in getSavedTimetables: $e");
      throw const ApiException('Failed to get saved timetables.');
    }
  }
}
