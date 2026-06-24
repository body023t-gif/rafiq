import 'package:rafiq/features/study%20plan/models/study_plan_model.dart';

sealed class StudyPlanState {
  const StudyPlanState();
}

class StudyPlanInitial extends StudyPlanState {
  const StudyPlanInitial();
}

class StudyPlanLoading extends StudyPlanState {
  const StudyPlanLoading();
}

class StudyPlanLoaded extends StudyPlanState {
  final StudyPlanModel plan;

  const StudyPlanLoaded(this.plan);
}

class StudyPlanEmpty extends StudyPlanState {
  const StudyPlanEmpty();
}

class StudyPlanError extends StudyPlanState {
  final String message;

  const StudyPlanError(this.message);
}
