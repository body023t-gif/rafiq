class CheckConfirmationCodeCommand {
  final String email;
  final String confirmationCode;

  CheckConfirmationCodeCommand({
    required this.email,
    required this.confirmationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'confirmationCode': confirmationCode,
    };
  }

  factory CheckConfirmationCodeCommand.fromJson(Map<String, dynamic> json) {
    return CheckConfirmationCodeCommand(
      email: json['email'] as String? ?? '',
      confirmationCode: json['confirmationCode'] as String? ?? '',
    );
  }
}
