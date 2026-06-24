import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/schedule_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  const ScheduleRepository(this.remoteDataSource);

  Future<StudentScheduleModel> getSchedule() async {
    try {
      final data = await remoteDataSource.getSchedule();
      return StudentScheduleModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load schedule.');
    }
  }
}
