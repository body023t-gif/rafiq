import 'dart:developer';

import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/chat%20ai/data/datasource/career_remote_datasource.dart';
import 'package:rafiq/features/chat%20ai/models/career_suggestion_model.dart';

class CareerRepository {
  final CareerRemoteDataSource remoteDataSource;

  const CareerRepository(this.remoteDataSource);

  Future<List<CareerSuggestionModel>> getCareerSuggestions(String studentId) async {
    try {
      final rawList = await remoteDataSource.getCareerSuggestions(studentId);
      final models = rawList.map(CareerSuggestionModel.fromJson).toList();
      
      log('[CareerRepository] Parsed models successfully');
      log('  - parsed item count: ${models.length}');
      for (var i = 0; i < models.length; i++) {
        final m = models[i];
        log('  - [$i] id: ${m.id}, careerPath: ${m.careerPath}, justification: ${m.justification}');
      }
      
      return models;
    } on ApiException {
      rethrow;
    } catch (e) {
      log('[CareerRepository] Error mapping models: $e');
      throw const ApiException('Failed to load career suggestions.');
    }
  }
}
