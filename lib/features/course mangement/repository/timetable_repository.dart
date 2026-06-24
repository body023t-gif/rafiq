import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/data/datasource/timetable_remote_datasource.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';

class TimetableRepository {
  final TimetableRemoteDataSource remoteDataSource;

  const TimetableRepository(this.remoteDataSource);

  Future<TimetableModel> generateTimetable(TimetableRequestModel request) async {
    try {
      final data = await remoteDataSource.generateTimetable(request.toJson());
      return TimetableModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to generate timetable.');
    }
  }

  Future<TimetableModel> saveTimetable(SaveTimetableRequestModel request) async {
    try {
      final data = await remoteDataSource.saveTimetable(request.toJson());
      return TimetableModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to save timetable.');
    }
  }
}
