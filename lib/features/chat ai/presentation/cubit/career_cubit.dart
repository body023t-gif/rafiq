import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/career_state.dart';
import 'package:rafiq/features/chat%20ai/repository/career_repository.dart';

class CareerCubit extends Cubit<CareerState> {
  final CareerRepository repository;

  CareerCubit(this.repository) : super(const CareerInitial());

  Future<void> loadCareerSuggestions(String studentId) async {
    if (studentId.trim().isEmpty) {
      log('[CareerCubit] studentId is empty, emitting CareerEmpty');
      emit(const CareerEmpty());
      return;
    }
    emit(const CareerLoading());
    log('[CareerCubit] Starting loadCareerSuggestions for studentId: $studentId');
    try {
      final suggestions = await repository.getCareerSuggestions(studentId);
      log('[CareerCubit] Loaded ${suggestions.length} suggestions');
      if (suggestions.isEmpty) {
        emit(const CareerEmpty());
      } else {
        emit(CareerLoaded(suggestions));
      }
    } on ApiException catch (e) {
      log('[CareerCubit] ApiException: ${e.message}');
      emit(CareerError(e.message));
    } catch (e) {
      log('[CareerCubit] Unexpected error: $e');
      emit(const CareerError('حدث خطأ غير متوقع أثناء تحميل الاقتراحات المهنية.'));
    }
  }
}
