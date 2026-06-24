import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';

sealed class TimetableState {
  const TimetableState();
}

class TimetableInitial extends TimetableState {
  const TimetableInitial();
}

class TimetableGenerating extends TimetableState {
  const TimetableGenerating();
}

class TimetableGenerated extends TimetableState {
  final TimetableModel timetable;

  const TimetableGenerated(this.timetable);
}

class TimetableSaving extends TimetableState {
  final TimetableModel timetable;

  const TimetableSaving(this.timetable);
}

class TimetableSaved extends TimetableState {
  final TimetableModel timetable;
  final String message;

  const TimetableSaved({
    required this.timetable,
    this.message = 'تم حفظ الجدول بنجاح',
  });
}

class TimetableError extends TimetableState {
  final String message;
  final TimetableModel? previousTimetable;

  const TimetableError(this.message, {this.previousTimetable});
}

TimetableModel? readTimetable(TimetableState state) {
  return switch (state) {
    TimetableGenerated(:final timetable) => timetable,
    TimetableSaving(:final timetable) => timetable,
    TimetableSaved(:final timetable) => timetable,
    TimetableError(:final previousTimetable) => previousTimetable,
    _ => null,
  };
}

StudentScheduleModel? timetableAsSchedule(TimetableState state) {
  return readTimetable(state)?.toScheduleModel();
}
