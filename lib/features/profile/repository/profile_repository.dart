import 'package:rafiq/core/error/api_exception.dart';
import 'package:rafiq/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:rafiq/features/profile/models/profile_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepository(this.remoteDataSource);

  Future<ProfileModel> getProfile() async {
    try {
      final innerData = await remoteDataSource.getProfile();
      return ProfileModel.fromJson(innerData);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Failed to load profile data.');
    }
  }
}
