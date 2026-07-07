import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/schedule_state.dart';
import 'package:rafiq/features/course%20mangement/repository/schedule_repository.dart';
import 'package:rafiq/data/api/api_service.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  void log(String message) {
    ApiService.log(message);
  }
  final ScheduleRepository repository;

  @override
  void onChange(Change<ScheduleState> change) {
    super.onChange(change);
    log('🔄 [ScheduleCubit State Transition]:');
    log('  - From: ${change.currentState}');
    log('  - To: ${change.nextState}');
  }

  ScheduleCubit(this.repository) : super(const ScheduleInitial());

  Future<void> loadSchedule({bool silent = false}) async {
    if (!silent) {
      emit(const ScheduleLoading());
    }
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
