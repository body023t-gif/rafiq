import 'package:rafiq/core/utils/json_helpers.dart';

import 'dart:developer';

class RecommendationModel {
  final String courseCode;
  final String title;
  final String score;
  final String confidence;

  const RecommendationModel({
    required this.courseCode,
    required this.title,
    this.score = '',
    this.confidence = '',
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      courseCode: readString(json, ['courseCode', 'code']),
      title: readString(json, ['courseName', 'title', 'name', 'courseTitle']),
      score: readString(json, ['score', 'Score']),
      confidence: readString(json, ['confidence', 'Confidence']),
    );
  }
}

class CareerSuggestionModel {
  final String id;
  final String careerPath;
  final String justification;
  final String trackConfidence;
  final List<RecommendationModel> recommendations;
  final DateTime? createdAt;

  const CareerSuggestionModel({
    required this.id,
    required this.careerPath,
    required this.justification,
    this.trackConfidence = '',
    this.recommendations = const [],
    this.createdAt,
  });

  factory CareerSuggestionModel.fromJson(Map<String, dynamic> json) {
    final dateStr = readString(json, ['createdAt', 'created_at', 'CreatedAt']);
    DateTime? parsedDate;
    if (dateStr.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateStr);
    }
    
    final recsRaw = json['recommendations'];
    List<RecommendationModel> parsedRecs = [];
    if (recsRaw is List) {
      parsedRecs = recsRaw.map((e) {
        if (e is String) {
          return RecommendationModel(courseCode: '', title: e);
        } else if (e is Map<String, dynamic>) {
          return RecommendationModel.fromJson(e);
        }
        return const RecommendationModel(courseCode: '', title: 'Unknown');
      }).toList();
    }
    
    log('[CareerSuggestionModel] Parsed ${parsedRecs.length} recommendations');
    for (int i = 0; i < parsedRecs.length; i++) {
      log('  - [$i] code: ${parsedRecs[i].courseCode}, title: ${parsedRecs[i].title}');
    }

    return CareerSuggestionModel(
      id: readString(json, ['id', 'Guid', 'Id']),
      careerPath: readString(json, ['careerPath', 'CareerPath', 'dominantTrack']),
      justification: readString(json, ['justification', 'Justification', 'trackReasoning']),
      trackConfidence: readString(json, ['trackConfidence']),
      recommendations: parsedRecs,
      createdAt: parsedDate,
    );
  }
}
