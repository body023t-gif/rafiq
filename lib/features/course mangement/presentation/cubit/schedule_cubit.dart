import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository repository;

  ScheduleCubit(this.repository) : super(const ScheduleInitial());

  Future<void> loadSchedule() async {
    emit(const ScheduleLoading());
    try {
      final schedule = await repository.getSchedule();
      if (schedule.entries.isEmpty) {
        emit(const ScheduleEmpty());
      } else {
        emit(ScheduleLoaded(schedule));
      }
    } on ApiException catch (e) {
      emit(ScheduleError(e.message));
    } catch (_) {
      emit(const ScheduleError('Failed to load schedule.'));
    }
  }

  Future<void> retry() async {
    await loadSchedule();
  }
}
