import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';

sealed class ScheduleState {
  const ScheduleState();
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final StudentScheduleModel schedule;

  const ScheduleLoaded(this.schedule);
}

class ScheduleEmpty extends ScheduleState {
  const ScheduleEmpty();
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);
}
