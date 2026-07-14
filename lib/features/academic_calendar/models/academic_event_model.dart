import 'package:rafiq/core/utils/json_helpers.dart';

class AcademicEventModel {
  final String id;
  final String eventName;
  final String description;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String location;
  final String eventType;
  final String status;

  AcademicEventModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.eventType,
    required this.status,
  });

  factory AcademicEventModel.fromJson(Map<String, dynamic> json) {
    return AcademicEventModel(
      id: readString(json, ['id', 'eventId', '_id']),
      eventName: readString(json, ['eventName', 'name', 'title']),
      description: readString(json, ['description', 'details', 'body']),
      eventDate: DateTime.tryParse(readString(json, ['eventDate', 'date'])) ?? DateTime.now(),
      startTime: readString(json, ['startTime', 'timeFrom', 'start_time']),
      endTime: readString(json, ['endTime', 'timeTo', 'end_time']),
      location: readString(json, ['location', 'place', 'venue']),
      eventType: readString(json, ['eventType', 'type', 'category']),
      status: readString(json, ['status', 'state']),
    );
  }
}
