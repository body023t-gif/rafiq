import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:rafiq/data/api/api_service.dart';

void main() {
  test('Investigate unwrap logic', () async {
    final apiService = ApiService(baseUrl: 'http://test.com');
    
    // Simulate study plan response
    final Map<String, dynamic> studyPlanRootResponse = {
      "success": true,
      "semesters": [
        {
          "semesterName": "Fall 2026",
          "courses": []
        }
      ],
      "courses": []
    };

    try {
      // Simulate calling unwrapObject directly or via a public method
      // Since unwrap is private, we'll just test the get method with mock dio if needed.
      // But we can just use the known logic:
      final innerData = studyPlanRootResponse['data'];
      final success = studyPlanRootResponse['success'];
      
      print("innerData: $innerData");
      print("success: $success");
      
      Map<String, dynamic> unwrapped;
      if (innerData == null && success == true) {
        unwrapped = const {};
      } else {
        unwrapped = innerData;
      }
      print("Unwrapped object: $unwrapped");
      print("Empty check: ${unwrapped.isEmpty}");
      
    } catch (e) {
      print(e);
    }
  });
}
