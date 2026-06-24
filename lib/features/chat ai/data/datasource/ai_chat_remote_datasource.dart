import 'package:rafiq/core/network/api_service.dart';

class AiChatRemoteDataSource {
  final ApiService apiService;

  const AiChatRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> askQuestion(Map<String, dynamic> body) {
    return apiService.post('/v1/api/ai/ask', body: body);
  }

  Future<List<Map<String, dynamic>>> getSessions() {
    return apiService.getList('/v1/api/ai/sessions');
  }

  Future<List<Map<String, dynamic>>> getHistory({String? sessionId}) {
    return apiService.getList(
      '/v1/api/ai/history',
      queryParameters: {
        if (sessionId != null && sessionId.isNotEmpty) 'sessionId': sessionId,
      },
    );
  }
}
