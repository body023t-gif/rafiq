import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafiq/features/auth/repository/auth_repository.dart';
import 'package:rafiq/features/auth/data/models/sign_in_command.dart';
import 'package:rafiq/features/auth/data/models/reset_password_command.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  Future<void> login(SignInCommand command) async {
    emit(AuthLoading());
    try {
      log('DEBUG [AuthCubit]: Attempting login...');
      final response = await _repository.login(command);
      log('DEBUG [AuthCubit]: Login success. Emitting AuthSuccess.');
      emit(AuthSuccess(response));
    } catch (e) {
      log('DEBUG [AuthCubit]: Login exception caught in Cubit: $e');
      final errorState = AuthError(error: e.toString());
      log('DEBUG [AuthCubit]: Emitting AuthError: ${errorState.error}');
      emit(errorState);
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      log('DEBUG [AuthCubit]: Attempting forgotPassword for $email...');
      await _repository.forgotPassword(email);
      log('DEBUG [AuthCubit]: ForgotPassword success. Emitting ForgotPasswordSuccess.');
      emit(const ForgotPasswordSuccess('Reset password email sent successfully.'));
    } catch (e) {
      log('DEBUG [AuthCubit]: ForgotPassword exception: $e');
      emit(AuthError(error: e.toString()));
    }
  }

  Future<void> resetPassword(ResetPasswordCommand command) async {
    emit(AuthLoading());
    try {
      log('DEBUG [AuthCubit]: Attempting resetPassword for ${command.email}...');
      await _repository.resetPassword(command);
      log('DEBUG [AuthCubit]: ResetPassword success. Emitting ResetPasswordSuccess.');
      emit(const ResetPasswordSuccess('Password reset successfully.'));
    } catch (e) {
      log('DEBUG [AuthCubit]: ResetPassword exception: $e');
      emit(AuthError(error: e.toString()));
    }
  }
}
