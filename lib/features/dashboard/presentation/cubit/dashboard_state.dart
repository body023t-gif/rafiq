import 'package:rafiq/features/dashboard/models/dashboard_model.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardModel dashboard;

  const DashboardLoaded(this.dashboard);
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);
}
