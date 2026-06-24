import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/study%20plan/presentation/cubit/study_plan_state.dart';
import 'package:rafiq/features/study%20plan/repository/study_plan_repository.dart';

class StudyPlanCubit extends Cubit<StudyPlanState> {
  final StudyPlanRepository repository;

  StudyPlanCubit(this.repository) : super(const StudyPlanInitial());

  Future<void> loadStudyPlan(String studentId) async {
    emit(const StudyPlanLoading());
    try {
      final plan = await repository.getStudyPlan(studentId);
      if (plan.isEmpty) {
        emit(const StudyPlanEmpty());
      } else {
        emit(StudyPlanLoaded(plan));
      }
    } on ApiException catch (e) {
      emit(StudyPlanError(e.message));
    } catch (_) {
      emit(const StudyPlanError('Failed to load study plan.'));
    }
  }

  Future<void> retry(String studentId) async {
    await loadStudyPlan(studentId);
  }
}
