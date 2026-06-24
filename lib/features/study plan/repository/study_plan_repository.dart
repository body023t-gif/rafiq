import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/study%20plan/data/datasource/study_plan_remote_datasource.dart';
import 'package:rafiq/features/study%20plan/models/study_plan_model.dart';

class StudyPlanRepository {
  final StudyPlanRemoteDataSource remoteDataSource;

  const StudyPlanRepository(this.remoteDataSource);

  Future<StudyPlanModel> getStudyPlan(String studentId) async {
    try {
      final data = await remoteDataSource.getStudyPlan(studentId);
      return StudyPlanModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load study plan.');
    }
  }
}
