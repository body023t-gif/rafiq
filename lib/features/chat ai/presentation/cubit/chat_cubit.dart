import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/chat%20ai/models/chat_model.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/chat_state.dart';
import 'package:rafiq/features/chat%20ai/repository/ai_chat_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  final AiChatRepository repository;

  ChatCubit(this.repository) : super(const ChatInitial());

  List<ChatMessageModel> _messages = [];
  List<ChatSessionModel> _sessions = [];
  String? _activeSessionId;

  Future<void> initialize() async {
    emit(const ChatLoading());
    try {
      _sessions = await repository.getSessions();
      _activeSessionId = _sessions.isNotEmpty ? _sessions.first.id : null;
      _messages = await repository.getHistory(sessionId: _activeSessionId);
      emit(
        ChatLoaded(
          messages: _messages,
          sessions: _sessions,
          activeSessionId: _activeSessionId,
        ),
      );
    } on ApiException catch (e) {
      emit(
        ChatError(
          message: e.message,
          messages: _messages,
          activeSessionId: _activeSessionId,
        ),
      );
    } catch (_) {
      emit(
        const ChatError(
          message: 'Failed to load chat.',
        ),
      );
    }
  }

  Future<void> loadHistory({String? sessionId}) async {
    emit(const ChatLoading());
    try {
      _activeSessionId = sessionId;
      _messages = await repository.getHistory(sessionId: sessionId);
      emit(
        ChatLoaded(
          messages: _messages,
          sessions: _sessions,
          activeSessionId: _activeSessionId,
        ),
      );
    } on ApiException catch (e) {
      emit(
        ChatError(
          message: e.message,
          messages: _messages,
          activeSessionId: _activeSessionId,
        ),
      );
    } catch (_) {
      emit(
        ChatError(
          message: 'Failed to load chat history.',
          messages: _messages,
          activeSessionId: _activeSessionId,
        ),
      );
    }
  }

  Future<void> sendQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state is ChatLoaded && (state as ChatLoaded).isSending) {
      return;
    }

    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isBot: false,
      sessionId: _activeSessionId,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, userMessage];
    emit(
      ChatLoaded(
        messages: _messages,
        sessions: _sessions,
        activeSessionId: _activeSessionId,
        isSending: true,
      ),
    );

    try {
      final response = await repository.askQuestion(
        AskQuestionRequestModel(
          question: trimmed,
          sessionId: _activeSessionId,
        ),
      );
      _activeSessionId = response.sessionId.isNotEmpty
          ? response.sessionId
          : _activeSessionId;
      _messages = [
        ..._messages,
        ChatMessageModel(
          id: response.messageId ?? '${DateTime.now().millisecondsSinceEpoch}-bot',
          text: response.answer,
          isBot: true,
          sessionId: _activeSessionId,
          createdAt: DateTime.now(),
        ),
      ];
      emit(
        ChatLoaded(
          messages: _messages,
          sessions: _sessions,
          activeSessionId: _activeSessionId,
        ),
      );
    } on ApiException catch (e) {
      emit(
        ChatError(
          message: e.message,
          messages: _messages,
          activeSessionId: _activeSessionId,
        ),
      );
    } catch (_) {
      emit(
        ChatError(
          message: 'Failed to send message.',
          messages: _messages,
          activeSessionId: _activeSessionId,
        ),
      );
    }
  }

  void addLocalMessage(ChatMessageModel message) {
    _messages = [..._messages, message];
    if (state is ChatLoaded) {
      emit((state as ChatLoaded).copyWith(messages: _messages));
    } else {
      emit(
        ChatLoaded(
          messages: _messages,
          sessions: _sessions,
          activeSessionId: _activeSessionId,
        ),
      );
    }
  }
}
