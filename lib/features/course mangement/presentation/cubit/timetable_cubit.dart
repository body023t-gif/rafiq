import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_state.dart';
import 'package:rafiq/features/course%20mangement/repository/timetable_repository.dart';

class TimetableCubit extends Cubit<TimetableState> {
  final TimetableRepository repository;

  TimetableCubit(this.repository) : super(const TimetableInitial());

  TimetableModel? _current;

  Future<void> generate({
    required TimetableStrategy strategy,
    List<String> courseIds = const [],
  }) async {
    emit(const TimetableGenerating());
    try {
      final timetable = await repository.generateTimetable(
        TimetableRequestModel(strategy: strategy, courseIds: courseIds),
      );
      _current = timetable;
      emit(TimetableGenerated(timetable));
    } on ApiException catch (e) {
      emit(TimetableError(e.message, previousTimetable: _current));
    } catch (_) {
      emit(TimetableError('Failed to generate timetable.', previousTimetable: _current));
    }
  }

  Future<void> regenerate({
    required TimetableStrategy strategy,
    List<String> courseIds = const [],
  }) async {
    await generate(strategy: strategy, courseIds: courseIds);
  }

  Future<void> save({List<String> entryIds = const [], StudentScheduleModel? schedule}) async {
    TimetableModel? current = _current ?? readTimetable(state);

    if (current == null && schedule != null) {
      current = TimetableModel(
        totalHours: schedule.totalHours,
        registeredCoursesCount: schedule.registeredCoursesCount,
        entries: schedule.entries,
      );
    }

    if (current == null) {
      emit(const TimetableError('No timetable to save.'));
      return;
    }

    emit(TimetableSaving(current));
    try {
      final ids = entryIds.isNotEmpty
          ? entryIds
          : current.entries.map((e) => e.id).where((id) => id.isNotEmpty).toList();

      final saved = await repository.saveTimetable(
        SaveTimetableRequestModel(entryIds: ids),
      );
      _current = saved;
      emit(TimetableSaved(timetable: saved));
    } on ApiException catch (e) {
      emit(TimetableError(e.message, previousTimetable: current));
    } catch (_) {
      emit(TimetableError('Failed to save timetable.', previousTimetable: current));
    }
  }
}
