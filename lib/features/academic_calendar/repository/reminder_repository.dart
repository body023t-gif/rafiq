import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/academic_calendar/data/datasource/reminder_remote_datasource.dart';

class ReminderRepository {
  final ReminderRemoteDataSource remoteDataSource;

  const ReminderRepository(this.remoteDataSource);

  Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      return await remoteDataSource.getReminders();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load reminders.');
    }
  }

  Future<Map<String, dynamic>> addReminder(Map<String, dynamic> body) async {
    try {
      return await remoteDataSource.addReminder(body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to add reminder.');
    }
  }

  Future<Map<String, dynamic>> updateReminder(String id, Map<String, dynamic> body) async {
    try {
      return await remoteDataSource.updateReminder(id, body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to update reminder.');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await remoteDataSource.deleteReminder(id);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to delete reminder.');
    }
  }
}
