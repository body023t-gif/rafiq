import 'package:rafiq/features/chat%20ai/models/career_suggestion_model.dart';

sealed class CareerState {
  const CareerState();
}

class CareerInitial extends CareerState {
  const CareerInitial();
}

class CareerLoading extends CareerState {
  const CareerLoading();
}

class CareerLoaded extends CareerState {
  final List<CareerSuggestionModel> suggestions;

  const CareerLoaded(this.suggestions);
}

class CareerEmpty extends CareerState {
  const CareerEmpty();
}

class CareerError extends CareerState {
  final String message;

  const CareerError(this.message);
}
