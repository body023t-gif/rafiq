import 'package:rafiq/features/auth/data/models/sign_response.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final SignResponse data;
  const AuthSuccess(this.data);
}

class AuthError extends AuthState {
  final String error;
  const AuthError({required this.error});
}

class ForgotPasswordSuccess extends AuthState {
  final String message;
  const ForgotPasswordSuccess(this.message);
}

class ResetPasswordSuccess extends AuthState {
  final String message;
  const ResetPasswordSuccess(this.message);
}
