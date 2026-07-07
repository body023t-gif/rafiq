import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/chat%20ai/models/chat_model.dart';
import 'package:rafiq/features/chat%20ai/repository/ai_chat_repository.dart';
import 'ai_assistant_state.dart';

class AiAssistantCubit extends Cubit<AiAssistantState> {
  final AiChatRepository repository;
  double? userGpa;
  String? userCareer;

  AiAssistantCubit(this.repository) : super(AiInitialState());

  void sendMessage(String question, String sessionId) async {
    emit(AiLoadingState());

    try {
      final request = AskQuestionRequestModel(
        question: question,
        sessionId: sessionId.isEmpty ? null : sessionId,
      );
      final response = await repository.askQuestion(request);
      emit(AiSuccessState(response.toJson()));
    } catch (e) {
      emit(AiErrorState(e.toString()));
    }
  }

  void saveGpa(double calculatedGpa) {
    userGpa = calculatedGpa;
  }

  void saveCareer(String career) {
    userCareer = career;
  }
}
