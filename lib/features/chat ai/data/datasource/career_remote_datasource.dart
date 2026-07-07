import 'dart:developer';

import 'package:rafiq/core/network/api_service.dart';

class CareerRemoteDataSource {
  final ApiService apiService;

  const CareerRemoteDataSource(this.apiService);

  Future<List<Map<String, dynamic>>> getCareerSuggestions(String studentId) async {
    final path = '/v1/api/ai/recommendations?studentId=$studentId';
    
    // Explicit logging
    log('[CareerRemoteDataSource] Requesting Career Suggestions');
    log('[CareerRemoteDataSource] GET $path');
    
    try {
      // The backend returns a single object containing dominantTrack etc.
      // We wrap it in a list to preserve the existing architecture.
      final data = await apiService.get(path);
      
      log('[CareerRemoteDataSource] Response received successfully');
      log('[CareerRemoteDataSource] Parsed data from ApiService: $data');
      return [data];
    } catch (e) {
      log('[CareerRemoteDataSource] Error occurred: $e');
      rethrow;
    }
  }
}
