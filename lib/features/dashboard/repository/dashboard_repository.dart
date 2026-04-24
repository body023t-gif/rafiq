import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:rafiq/features/dashboard/models/dashboard_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  const DashboardRepository(this.remoteDataSource);

  Future<DashboardModel> getDashboard(String userId) async {
    try {
      final response = await remoteDataSource.getDashboard(userId);
      return DashboardModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load dashboard data.');
    }
  }
}
