import 'package:rafiq/features/academic_calendar/models/academic_event_model.dart';

abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final Map<DateTime, List<AcademicEventModel>> groupedEvents;
  final List<AcademicEventModel> allEvents;

  EventLoaded({required this.groupedEvents, required this.allEvents});
}

class EventError extends EventState {
  final String message;

  EventError(this.message);
}
