import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/profile/presentation/cubit/profile_state.dart';
import 'package:rafiq/features/profile/repository/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit(this.repository) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final profile = await repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> retry() async {
    await loadProfile();
  }
}
