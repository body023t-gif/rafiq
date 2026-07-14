import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/academic_calendar/models/academic_event_model.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/event_state.dart';
import 'package:rafiq/features/academic_calendar/repository/event_repository.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository repository;

  EventCubit(this.repository) : super(EventInitial());

  Future<void> loadEvents() async {
    // Only load if not already loaded to satisfy "Load Academic Events once when entering the Calendar screen."
    if (state is EventLoaded) return;
    
    emit(EventLoading());
    try {
      final events = await repository.getAcademicEvents();
      
      final Map<DateTime, List<AcademicEventModel>> grouped = {};
      
      for (final event in events) {
        // Group events using only year, month, day. Ignore time.
        final dateKey = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day);
        
        if (grouped.containsKey(dateKey)) {
          grouped[dateKey]!.add(event);
        } else {
          grouped[dateKey] = [event];
        }
      }
      
      emit(EventLoaded(groupedEvents: grouped, allEvents: events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
