import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/student_services/presentation/cubit/student_services_state.dart';
import 'package:rafiq/features/student_services/repository/student_services_repository.dart';
import 'package:rafiq/features/student_services/models/document_request_command.dart';

class StudentServicesCubit extends Cubit<StudentServicesState> {
  final StudentServicesRepository repository;

  StudentServicesCubit(this.repository) : super(const StudentServicesInitial()) {
    log('[Cubit State Transition] StudentServicesCubit Initialized: $state');
  }

  @override
  void onChange(Change<StudentServicesState> change) {
    super.onChange(change);
    log('[Cubit State Transition] State changed:');
    log('  - Current state: ${change.currentState}');
    log('  - Next state: ${change.nextState}');
  }

  Future<void> loadInitialData() async {
    log('[Booking] Calling StudentServicesCubit.loadInitialData...');
    emit(const StudentServicesInitialDataLoading());
    try {
      final data = await repository.getInitialData();
      emit(StudentServicesInitialDataLoaded(data));
    } on ApiException catch (e) {
      emit(StudentServicesInitialDataError(e.message));
    } catch (e) {
      emit(StudentServicesInitialDataError('Failed to load initial data: $e'));
    }
  }

  Future<void> bookService({
    required int serviceType,
    required DateTime appointmentDate,
    required String time,
    required String notes,
  }) async {
    log('[Booking] Calling StudentServicesCubit.bookService...');
    log('  - Parameters: serviceType: $serviceType, appointmentDate: $appointmentDate, time: $time, notes: $notes');
    emit(const StudentServicesLoading());
    try {
      final body = {
        "serviceType": serviceType,
        "appointmentDate": appointmentDate.toIso8601String(),
        "time": time,
        "notes": notes,
      };
      await repository.bookService(body);
      emit(const StudentServicesBookingSuccess('Service booked successfully'));
    } on ApiException catch (e) {
      emit(StudentServicesError(e.message));
    } catch (e) {
      emit(StudentServicesError('Failed to book service: $e'));
    }
  }

  Future<void> sendGuidanceRequest({
    required String studentId,
    required String title,
    required String description,
  }) async {
    log('[Booking] Calling StudentServicesCubit.sendGuidanceRequest...');
    log('  - Parameters: studentId: $studentId, title: $title, description: $description');
    emit(const StudentServicesLoading());
    try {
      final body = {
        "studentId": studentId,
        "title": title,
        "description": description,
      };
      await repository.sendGuidanceRequest(body);
      emit(const StudentServicesBookingSuccess('Guidance request sent successfully'));
    } on ApiException catch (e) {
      emit(StudentServicesError(e.message));
    } catch (e) {
      emit(StudentServicesError('Failed to send guidance request: $e'));
    }
  }

  Future<void> requestDocument({
    required String studentId,
    required String documentType,
    required String remarks,
    required String topic,
  }) async {
    log('[Booking] Calling StudentServicesCubit.requestDocument...');
    log('  - Parameters: studentId: $studentId, documentType: $documentType, remarks: $remarks, topic: $topic');
    emit(const StudentServicesLoading());
    try {
      final command = DocumentRequestCommand(
        studentId: studentId,
        documentType: documentType,
        remarks: remarks,
        topic: topic,
      );
      await repository.requestDocument(command);
      emit(const StudentServicesBookingSuccess('Document requested successfully'));
    } on ApiException catch (e) {
      emit(StudentServicesError(e.message));
    } catch (e) {
      emit(StudentServicesError('Failed to request document: $e'));
    }
  }
}
