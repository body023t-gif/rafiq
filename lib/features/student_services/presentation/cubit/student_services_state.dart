import 'package:rafiq/features/student_services/models/initial_data_model.dart';

sealed class StudentServicesState {
  const StudentServicesState();
}

class StudentServicesInitial extends StudentServicesState {
  const StudentServicesInitial();
}

class StudentServicesLoading extends StudentServicesState {
  const StudentServicesLoading();
}

class StudentServicesBookingSuccess extends StudentServicesState {
  final String message;
  const StudentServicesBookingSuccess(this.message);
}

class StudentServicesError extends StudentServicesState {
  final String message;
  const StudentServicesError(this.message);
}

// Initial Data States
class StudentServicesInitialDataLoading extends StudentServicesState {
  const StudentServicesInitialDataLoading();
}

class StudentServicesInitialDataLoaded extends StudentServicesState {
  final AcademicServiceInitialDataModel initialData;
  const StudentServicesInitialDataLoaded(this.initialData);
}

class StudentServicesInitialDataError extends StudentServicesState {
  final String message;
  const StudentServicesInitialDataError(this.message);
}
