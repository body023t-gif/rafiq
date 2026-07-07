class ActivateUniversityEmailCommand {
  final String email;
  final String confirmationCode;

  ActivateUniversityEmailCommand({
    required this.email,
    required this.confirmationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'confirmationCode': confirmationCode,
    };
  }

  factory ActivateUniversityEmailCommand.fromJson(Map<String, dynamic> json) {
    return ActivateUniversityEmailCommand(
      email: json['email'] as String? ?? '',
      confirmationCode: json['confirmationCode'] as String? ?? '',
    );
  }
}
