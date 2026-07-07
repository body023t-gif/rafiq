abstract class AiAssistantState {}

class AiInitialState extends AiAssistantState {}

class AiLoadingState extends AiAssistantState {}

class AiSuccessState extends AiAssistantState {
  final Map<String, dynamic> response;
  AiSuccessState(this.response);
}

class AiErrorState extends AiAssistantState {
  final String error;
  AiErrorState(this.error);
}
