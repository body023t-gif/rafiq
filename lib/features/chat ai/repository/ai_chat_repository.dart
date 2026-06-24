import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/chat%20ai/data/datasource/ai_chat_remote_datasource.dart';
import 'package:rafiq/features/chat%20ai/models/chat_model.dart';

class AiChatRepository {
  final AiChatRemoteDataSource remoteDataSource;

  const AiChatRepository(this.remoteDataSource);

  Future<AskQuestionResponseModel> askQuestion(AskQuestionRequestModel request) async {
    try {
      final data = await remoteDataSource.askQuestion(request.toJson());
      return AskQuestionResponseModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to send question.');
    }
  }

  Future<List<ChatSessionModel>> getSessions() async {
    try {
      final items = await remoteDataSource.getSessions();
      return items.map(ChatSessionModel.fromJson).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load chat sessions.');
    }
  }

  Future<List<ChatMessageModel>> getHistory({String? sessionId}) async {
    try {
      final items = await remoteDataSource.getHistory(sessionId: sessionId);
      return items.map(ChatMessageModel.fromJson).toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load chat history.');
    }
  }
}
