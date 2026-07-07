import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/data/api/api_service.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  const ScheduleRepository(this.remoteDataSource);

  void log(String message) {
    ApiService.log(message);
  }

  Future<StudentScheduleModel> getSchedule() async {
    log('[Schedule Trace] Calling ScheduleRepository.getSchedule...');
    try {
      final data = await remoteDataSource.getSchedule();
      log('[Schedule Trace] GET /v1/api/students/schedule response status: 200');
      log('[Schedule Trace] Raw Response: $data');

      final schedule = StudentScheduleModel.fromJson(data);
      log('[Schedule Trace] Number of entries: ${schedule.entries.length}');

      final Map<String, int> lectureGroupCounts = {};
      for (final entry in schedule.entries) {
        log('  - Entry details:');
        log('    * CourseId: ${entry.courseId}');
        log('    * CourseCode: ${entry.courseCode}');
        log('    * LectureGroupId: ${entry.lectureGroupId}');
        log('    * Day: ${entry.day}');
        log('    * Time: ${entry.startTime} - ${entry.endTime}');
        log('    * Section: ${entry.sectionName}');
        log('    * Instructor: ${entry.instructorName}');
        
        final lgId = entry.lectureGroupId;
        if (lgId != null && lgId.isNotEmpty) {
          lectureGroupCounts[lgId] = (lectureGroupCounts[lgId] ?? 0) + 1;
        }
      }

      final duplicates = lectureGroupCounts.entries.where((e) => e.value > 1).toList();
      if (duplicates.isNotEmpty) {
        log('⚠️ WARNING: Duplicate LectureGroupIds found:');
        for (final dup in duplicates) {
          log('  - LectureGroupId: ${dup.key} appears ${dup.value} times');
        }
      } else {
        log('ℹ️ INFO: No duplicate LectureGroupIds found.');
      }

      return schedule;
    } on ApiException catch (e) {
      log("ApiException in getSchedule: $e");
      rethrow;
    } catch (e) {
      log("Unexpected error in getSchedule: $e");
      throw const ApiException('Failed to load schedule.');
    }
  }
}
