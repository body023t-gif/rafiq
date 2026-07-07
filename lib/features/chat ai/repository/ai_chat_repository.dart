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
      final List<ChatMessageModel> messages = [];
      for (final item in items) {
        final id = item['id']?.toString() ?? item['messageId']?.toString() ?? '';
        final session = item['sessionId']?.toString() ?? item['chatSessionId']?.toString() ?? sessionId ?? '';
        final question = item['question']?.toString() ?? '';
        final answer = item['answer']?.toString() ?? '';
        final askedAtStr = item['askedAt']?.toString() ?? item['createdAt']?.toString() ?? item['timestamp']?.toString() ?? '';
        final askedAt = DateTime.tryParse(askedAtStr);

        if (question.isNotEmpty || answer.isNotEmpty) {
          if (question.isNotEmpty) {
            messages.add(ChatMessageModel(
              id: '${id}_q',
              text: question,
              isBot: false,
              sessionId: session,
              createdAt: askedAt,
            ));
          }
          if (answer.isNotEmpty) {
            messages.add(ChatMessageModel(
              id: '${id}_a',
              text: answer,
              isBot: true,
              sessionId: session,
              createdAt: askedAt,
            ));
          }
        } else {
          messages.add(ChatMessageModel.fromJson(item));
        }
      }
      return messages;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load chat history.');
    }
  }
}
