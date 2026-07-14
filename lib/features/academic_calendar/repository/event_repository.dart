import 'package:rafiq/features/academic_calendar/data/datasource/event_remote_datasource.dart';
import 'package:rafiq/features/academic_calendar/models/academic_event_model.dart';

class EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepository(this.remoteDataSource);

  Future<List<AcademicEventModel>> getAcademicEvents() async {
    final events = await remoteDataSource.getAcademicEvents();
    
    // Filter only Published or Active events
    return events.where((e) {
      final status = e.status.toLowerCase();
      return status == 'published' || status == 'active';
    }).toList();
  }
}
