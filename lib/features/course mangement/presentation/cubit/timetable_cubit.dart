import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/core/utils/text_encoding.dart';
import 'package:rafiq/data/api/api_service.dart';
import 'package:rafiq/features/course%20mangement/models/schedule_model.dart';
import 'package:rafiq/features/course%20mangement/models/timetable_model.dart';
import 'package:rafiq/features/course%20mangement/presentation/cubit/timetable_state.dart';
import 'package:rafiq/features/course%20mangement/repository/timetable_repository.dart';

class TimetableCubit extends Cubit<TimetableState> {
  void log(String message) {
    ApiService.log(message);
  }
  final TimetableRepository repository;

  TimetableCubit(this.repository) : super(const TimetableInitial());

  @override
  void onChange(Change<TimetableState> change) {
    super.onChange(change);
    log('🔄 [TimetableCubit State Transition]:');
    log('  - From: ${change.currentState}');
    log('  - To: ${change.nextState}');
  }

  TimetableModel? _current;

  void resetAfterSave() {
    _current = null;
    emit(const TimetableInitial());
  }

  Future<void> generate({
    required TimetableStrategy strategy,
    List<String> courseIds = const [],
  }) async {
    log("IDs received by Cubit: $courseIds");
    emit(const TimetableGenerating());
    try {
      final timetable = await repository.generateTimetable(
        TimetableRequestModel(strategy: strategy, courseIds: courseIds),
      );
      _current = timetable;
      emit(TimetableGenerated(timetable));
    } on ApiException catch (e) {
      emit(TimetableError(repairUtf8Text(e.message), previousTimetable: _current));
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

    log('========== [Save Timetable Cubit Call] ==========');
    log('  - current timetable exists: ${current != null}');
    if (current != null) {
      log('  - current.rawJson exists: ${current.rawJson != null}');
      if (current.rawJson == null) {
        log('❌ ERROR: current.rawJson became null!');
        log('    * _current exists: ${_current != null}');
        log('    * readTimetable(state) returns non-null: ${readTimetable(state) != null}');
      }
    }

    if (current == null || current.rawJson == null) {
      emit(const TimetableError('لا يمكن حفظ جدول قبل توليده.'));
      return;
    }

    emit(TimetableSaving(current));
    try {
      final ids = entryIds.isNotEmpty
          ? entryIds
          : current.entries.map((e) => e.id).where((id) => id.isNotEmpty).toList();

      final studentId = ApiService.dynamicStudentId ?? ApiService.dynamicUserId ?? ApiService.staticUserId;
      final saved = await repository.saveTimetable(
        SaveTimetableRequestModel(
          entryIds: ids,
          studentId: studentId,
          timetableData: current.rawJson,
        ),
      );
      _current = saved;
      emit(TimetableSaved(timetable: saved));
    } on ApiException catch (e) {
      emit(TimetableError(repairUtf8Text(e.message), previousTimetable: current));
    } catch (_) {
      emit(TimetableError('Failed to save timetable.', previousTimetable: current));
    }
  }
}
