class SignInCommand {
  final String? email;
  final String? password;
  final String? fbToken;
  final bool? isAndroidDevice;
  final bool? isIosDevice;

  SignInCommand({
    this.email,
    this.password,
    this.fbToken,
    this.isAndroidDevice,
    this.isIosDevice,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (fbToken != null) 'fbToken': fbToken,
      if (isAndroidDevice != null) 'isAndroidDevice': isAndroidDevice,
      if (isIosDevice != null) 'isIosDevice': isIosDevice,
    };
  }

  factory SignInCommand.fromJson(Map<String, dynamic> json) {
    return SignInCommand(
      email: json['email'] as String?,
      password: json['password'] as String?,
      fbToken: json['fbToken'] as String?,
      isAndroidDevice: json['isAndroidDevice'] as bool?,
      isIosDevice: json['isIosDevice'] as bool?,
    );
  }
}
