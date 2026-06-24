import 'package:rafiq/core/utils/json_helpers.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isBot;
  final String? sessionId;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isBot,
    this.sessionId,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final role = readString(json, ['role', 'sender', 'messageType']).toLowerCase();
    final isBot = readBool(json, ['isBot', 'isAssistant']) ||
        role.contains('assistant') ||
        role.contains('bot') ||
        role.contains('ai');

    return ChatMessageModel(
      id: readString(json, ['id', 'messageId']),
      text: readString(json, ['text', 'message', 'content', 'answer', 'question']),
      isBot: isBot,
      sessionId: readString(json, ['sessionId', 'chatSessionId']),
      createdAt: _parseDate(readString(json, ['createdAt', 'timestamp', 'time'])),
    );
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class ChatSessionModel {
  final String id;
  final String title;
  final DateTime? lastMessageAt;

  const ChatSessionModel({
    required this.id,
    required this.title,
    this.lastMessageAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: readString(json, ['id', 'sessionId']),
      title: readString(json, ['title', 'name', 'subject'], 'محادثة'),
      lastMessageAt: DateTime.tryParse(
        readString(json, ['lastMessageAt', 'updatedAt', 'createdAt']),
      ),
    );
  }
}

class AskQuestionRequestModel {
  final String question;
  final String? sessionId;

  const AskQuestionRequestModel({
    required this.question,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      if (sessionId != null && sessionId!.isNotEmpty) 'sessionId': sessionId,
    };
  }
}

class AskQuestionResponseModel {
  final String answer;
  final String sessionId;
  final String? messageId;

  const AskQuestionResponseModel({
    required this.answer,
    required this.sessionId,
    this.messageId,
  });

  factory AskQuestionResponseModel.fromJson(Map<String, dynamic> json) {
    return AskQuestionResponseModel(
      answer: readString(json, ['answer', 'response', 'text', 'message']),
      sessionId: readString(json, ['sessionId', 'chatSessionId']),
      messageId: readString(json, ['messageId', 'id']),
    );
  }
}
