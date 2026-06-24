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

  const TimetableModel({
    required this.totalHours,
    required this.registeredCoursesCount,
    required this.entries,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    final schedule = StudentScheduleModel.fromJson(json);
    return TimetableModel(
      totalHours: schedule.totalHours,
      registeredCoursesCount: schedule.registeredCoursesCount,
      entries: schedule.entries,
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

  const SaveTimetableRequestModel({this.entryIds = const []});

  Map<String, dynamic> toJson() {
    return {
      if (entryIds.isNotEmpty) 'entryIds': entryIds,
      'save': true,
    };
  }
}
