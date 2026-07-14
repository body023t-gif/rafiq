import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/academic_calendar/models/academic_event_model.dart';
import 'dart:developer';

class EventRemoteDataSource {
  final ApiService apiService;

  EventRemoteDataSource(this.apiService);

  Future<List<AcademicEventModel>> getAcademicEvents() async {
    try {
      final response = await apiService.get('/v1/api/events/getall/pagginated');
      
      List<dynamic> items = [];
      if (response['data'] is List) {
        items = response['data'];
      } else if (response['items'] is List) {
        items = response['items'];
      } else if (response['content'] is List) {
        items = response['content'];
      } else if (response.containsKey('data') == false) {
        // sometimes the map itself is empty, wait, if the endpoint returns a list at the root, the get method might crash because it expects Map<String, dynamic>. But we already mapped it.
      }
      
      final events = items
          .map((json) => AcademicEventModel.fromJson(json as Map<String, dynamic>))
          .toList();
          
      return events;
    } catch (e) {
      log('Error fetching academic events: $e');
      throw Exception('فشل في جلب الفعاليات الأكاديمية: $e');
    }
  }
}
