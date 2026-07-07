import 'dart:developer';

import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/student_services/data/datasource/student_services_remote_datasource.dart';
import 'package:rafiq/features/student_services/models/initial_data_model.dart';
import 'package:rafiq/features/student_services/models/document_request_command.dart';

class StudentServicesRepository {
  final StudentServicesRemoteDataSource remoteDataSource;

  const StudentServicesRepository(this.remoteDataSource);

  Future<AcademicServiceInitialDataModel> getInitialData() async {
    log('[Booking] Calling StudentServicesRepository.getInitialData...');
    try {
      final data = await remoteDataSource.getInitialData();
      final model = AcademicServiceInitialDataModel.fromJson(data);
      log('[Booking] StudentServicesRepository.getInitialData Success: ${model.studentName}');
      return model;
    } on ApiException catch (e) {
      log('[Booking] StudentServicesRepository.getInitialData ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      log('[Booking] StudentServicesRepository.getInitialData Generic Error: $e');
      throw const ApiException('Failed to load initial data.');
    }
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> body) async {
    log('[Booking] Calling StudentServicesRepository.bookService...');
    try {
      final result = await remoteDataSource.bookService(body);
      log('[Booking] StudentServicesRepository.bookService Success');
      return result;
    } on ApiException catch (e) {
      log('[Booking] StudentServicesRepository.bookService ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      log('[Booking] StudentServicesRepository.bookService Generic Error: $e');
      throw const ApiException('Failed to book academic service.');
    }
  }

  Future<Map<String, dynamic>> sendGuidanceRequest(Map<String, dynamic> body) async {
    log('[Booking] Calling StudentServicesRepository.sendGuidanceRequest...');
    try {
      final result = await remoteDataSource.sendGuidanceRequest(body);
      log('[Booking] StudentServicesRepository.sendGuidanceRequest Success');
      return result;
    } on ApiException catch (e) {
      log('[Booking] StudentServicesRepository.sendGuidanceRequest ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      log('[Booking] StudentServicesRepository.sendGuidanceRequest Generic Error: $e');
      throw const ApiException('Failed to send guidance request.');
    }
  }

  Future<Map<String, dynamic>> requestDocument(DocumentRequestCommand command) async {
    log('[Booking] Calling StudentServicesRepository.requestDocument...');
    try {
      final result = await remoteDataSource.requestDocument(command);
      log('[Booking] StudentServicesRepository.requestDocument Success');
      return result;
    } on ApiException catch (e) {
      log('[Booking] StudentServicesRepository.requestDocument ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      log('[Booking] StudentServicesRepository.requestDocument Generic Error: $e');
      throw const ApiException('Failed to request document.');
    }
  }
}
