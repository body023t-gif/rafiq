class ResetPasswordCommand {
  final String? email;
  final String? token;
  final String? newPassword;

  ResetPasswordCommand({
    this.email,
    this.token,
    this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (token != null) 'token': token,
      if (newPassword != null) 'newPassword': newPassword,
    };
  }

  factory ResetPasswordCommand.fromJson(Map<String, dynamic> json) {
    return ResetPasswordCommand(
      email: json['email'] as String?,
      token: json['token'] as String?,
      newPassword: json['newPassword'] as String?,
    );
  }
}
