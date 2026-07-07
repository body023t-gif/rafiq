import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/academic_calendar/presentation/cubit/reminder_state.dart';
import 'package:rafiq/features/academic_calendar/repository/reminder_repository.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repository;

  ReminderCubit(this.repository) : super(const ReminderInitial());

  List<Map<String, dynamic>> _remindersList = [];

  Future<void> loadReminders() async {
    emit(const ReminderLoading());
    try {
      final list = await repository.getReminders();
      _remindersList = list;
      emit(ReminderLoaded(_remindersList));
    } on ApiException catch (e) {
      emit(ReminderError(e.message));
    } catch (_) {
      emit(const ReminderError('Failed to load reminders.'));
    }
  }

  Future<void> addReminder(String title, String description, DateTime date) async {
    emit(const ReminderLoading());
    try {
      final body = {
        "title": title,
        "description": description,
        "dueDate": date.toIso8601String(),
        "isCompleted": false
      };
      await repository.addReminder(body);
      emit(const ReminderActionSuccess('Reminder added successfully'));
      await loadReminders();
    } on ApiException catch (e) {
      emit(ReminderError(e.message));
    } catch (_) {
      emit(const ReminderError('Failed to add reminder.'));
    }
  }

  Future<void> toggleReminder(String id, bool currentStatus) async {
    final reminder = _remindersList.firstWhere((r) => r['id'] == id);
    try {
      final body = {
        "id": id,
        "title": reminder['title'],
        "description": reminder['description'],
        "dueDate": reminder['dueDate'],
        "isCompleted": !currentStatus
      };
      await repository.updateReminder(id, body);
      await loadReminders();
    } on ApiException catch (e) {
      emit(ReminderError(e.message));
    } catch (_) {
      // Local fallback in case of errors
      final idx = _remindersList.indexWhere((r) => r['id'] == id);
      if (idx != -1) {
        _remindersList[idx]['isCompleted'] = !currentStatus;
        emit(ReminderLoaded(List.from(_remindersList)));
      }
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await repository.deleteReminder(id);
      await loadReminders();
    } on ApiException catch (e) {
      emit(ReminderError(e.message));
    } catch (_) {
      // Local fallback in case of errors
      _remindersList.removeWhere((r) => r['id'] == id);
      emit(ReminderLoaded(List.from(_remindersList)));
    }
  }
}
