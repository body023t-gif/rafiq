import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:rafiq/features/dashboard/repository/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  DashboardCubit(this.repository) : super(const DashboardInitial());

  Future<void> loadDashboard(String userId) async {
    emit(const DashboardLoading());
    try {
      final dashboard = await repository.getDashboard(userId);
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> retry(String userId) async {
    await loadDashboard(userId);
  }
}
