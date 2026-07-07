import 'dart:convert';

import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';

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
          final role = claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? claims['role'] ?? 'Unknown';
          final expUnix = claims['exp'];
          DateTime? expTime;
          if (expUnix is num) {
            expTime = DateTime.fromMillisecondsSinceEpoch(expUnix.toInt() * 1000);
          }

          log('  - Student Email: $email');
          log('  - ApiService.dynamicStudentId: ${ApiService.dynamicStudentId}');
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

  Future<TimetableModel> generateTimetable(TimetableRequestModel request) async {
    logJwtAndUserInformation();
    log('========== [Generate Timetable Repository Call] ==========');
    log('  - Selected Course IDs: ${request.courseIds}');
    log('  - Selected Strategy: ${request.strategy.apiValue}');
    log('  - Number of Selected Courses: ${request.courseIds.length}');

    try {
      final Map<String, dynamic> coursesMap = {};
      final List<String> courseCodes = [];

      int parseDay(String dayStr) {
        switch (dayStr.trim()) {
          case 'الأحد': return 0;
          case 'الاثنين': return 1;
          case 'الثلاثاء': return 2;
          case 'الأربعاء': return 3;
          case 'الخميس': return 4;
          case 'الجمعة': return 5;
          case 'السبت': return 6;
          default: return 0;
        }
      }

      Map<String, String> parseTime(String timeRange) {
        final parts = timeRange.split('-');
        if (parts.isEmpty) return {'start': '08:00', 'duration': '2'};
        final startStr = parts.first.trim();
        String startVal = startStr;
        if (startVal.length == 4) startVal = '0$startVal';
        
        int durationVal = 2;
        if (parts.length > 1) {
          try {
            final endStr = parts[1].trim();
            final startHr = int.parse(startStr.split(':').first);
            final endHr = int.parse(endStr.split(':').first);
            durationVal = endHr - startHr;
          } catch (_) {}
        }
        return {'start': startVal, 'duration': durationVal.toString()};
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

          final lectureGroupsCount = lectureGroups is List ? lectureGroups.length : 0;
          final sectionsCount = sections is List ? sections.length : 0;

          log("lectureGroups type: ${lectureGroups?.runtimeType}, count: $lectureGroupsCount");
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
          if (groups == null || groups.isEmpty) {
            log("Skipped because no valid lecture groups exist (lectureGroups is null or empty).");
            continue;
          }

          var selectedGroup = groups.first;
          bool foundAvailable = false;
          for (final group in groups) {
            final capacity = group['capacity'] ?? 50;
            final enrolled = group['enrolledStudentsCount'] ?? 0;
            if (capacity - enrolled > 0) {
              selectedGroup = group;
              foundAvailable = true;
              break;
            }
          }

          if (!foundAvailable) {
            log("Skipped because no group has available seats (enrolled >= capacity).");
            continue;
          }

          final timeMap = parseTime(selectedGroup['time'].toString());
          coursesMap[id] = {
            'priority': 1,
            'difficulty': 1,
            'lecture': {
              'id': selectedGroup['id'],
              'day': parseDay(selectedGroup['day'].toString()),
              'start': timeMap['start'],
              'duration': int.tryParse(timeMap['duration'] ?? '2') ?? 2,
              'capacity': selectedGroup['capacity'] ?? 50,
              'available_seats': (selectedGroup['capacity'] ?? 50) - (selectedGroup['enrolledStudentsCount'] ?? 0),
            },
            'sections': [],
          };
          log("Successfully added course $id to coursesMap.");
        } catch (e, stackTrace) {
          log("Error fetching details for course $id: $e\n$stackTrace");
          log("Course: $id\nSkipped due to unexpected exception in detail fetch/parse.");
        }
      }

      log('  - Selected Course Codes: $courseCodes');
      log('  - Final Generated Courses Map: $coursesMap');

      final generateBody = {
        'option': request.strategy.apiValue,
        'courses': coursesMap,
      };

      log('  - Exact JSON Payload sent to POST /v1/api/ai/timetable:');
      log(json.encode(generateBody));
      log('================================================');

      final data = await remoteDataSource.generateTimetable(generateBody);
      return TimetableModel.fromJson(data);
    } on ApiException catch (e) {
      log("ApiException in generateTimetable: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in generateTimetable: $e");
      throw const ApiException('Failed to generate timetable.');
    }
  }

  Future<TimetableModel> saveTimetable(SaveTimetableRequestModel request) async {
    logJwtAndUserInformation();
    log('========== [Save Timetable Repository Call] ==========');
    log('  - StudentId: ${request.studentId}');
    log('  - TimetableName: (Default Save Request)');
    log('  - TimetableData (rawJson): ${request.timetableData}');
    log('  - Complete JSON exactly as sent:');
    log(json.encode(request.toJson()));
    log('======================================================');

    try {
      final data = await remoteDataSource.saveTimetable(request.toJson());
      return TimetableModel.fromJson(data);
    } on ApiException catch (e) {
      log("ApiException in saveTimetable: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in saveTimetable: $e");
      throw const ApiException('Failed to save timetable.');
    }
  }
}
