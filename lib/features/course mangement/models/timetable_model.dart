import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';

enum TimetableStrategy { compact, balanced }

extension TimetableStrategyX on TimetableStrategy {
  String get apiValue => switch (this) {
        TimetableStrategy.compact => 'compact',
        TimetableStrategy.balanced => 'balanced',
      };
}

class TimetableRequestModel {
  final TimetableStrategy strategy;
  final List<String> courseIds;

  const TimetableRequestModel({
    required this.strategy,
    this.courseIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy.apiValue,
      if (courseIds.isNotEmpty) 'courseIds': courseIds,
    };
  }
}

class TimetableModel {
  final int totalHours;
  final int registeredCoursesCount;
  final List<ScheduleEntryModel> entries;
  final Map<String, dynamic>? rawJson;

  const TimetableModel({
    required this.totalHours,
    required this.registeredCoursesCount,
    required this.entries,
    this.rawJson,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    final schedule = StudentScheduleModel.fromJson(json);
    return TimetableModel(
      totalHours: schedule.totalHours,
      registeredCoursesCount: schedule.registeredCoursesCount,
      entries: schedule.entries,
      rawJson: json,
    );
  }

  StudentScheduleModel toScheduleModel() {
    return StudentScheduleModel(
      totalHours: totalHours,
      registeredCoursesCount: registeredCoursesCount,
      entries: entries,
    );
  }
}

class SaveTimetableRequestModel {
  final List<String> entryIds;
  final String studentId;
  final Map<String, dynamic>? timetableData;

  const SaveTimetableRequestModel({
    required this.entryIds,
    required this.studentId,
    this.timetableData,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'timetableName': 'جدول دراسي مقترح',
      'timetableData': timetableData,
    };
  }
}
