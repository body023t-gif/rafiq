import 'package:rafiq/features/chat%20ai/models/chat_model.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  final List<ChatSessionModel> sessions;
  final String? activeSessionId;
  final bool isSending;

  const ChatLoaded({
    required this.messages,
    this.sessions = const [],
    this.activeSessionId,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    List<ChatMessageModel>? messages,
    List<ChatSessionModel>? sessions,
    String? activeSessionId,
    bool? isSending,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  final List<ChatMessageModel> messages;
  final String? activeSessionId;

  const ChatError({
    required this.message,
    this.messages = const [],
    this.activeSessionId,
  });
}
