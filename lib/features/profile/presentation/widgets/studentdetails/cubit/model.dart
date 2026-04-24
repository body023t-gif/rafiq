class ProfileUserModel {
  final String firstName;
  final String lastName;
  final String studentCode;
  final String nationalId;
  final String? imageUrl;

  ProfileUserModel({
    required this.firstName,
    required this.lastName,
    required this.studentCode,
    required this.nationalId,
    this.imageUrl,
  });

  /// ✅ constructor للحالة الفاضية (قبل API)
  factory ProfileUserModel.empty() {
    return ProfileUserModel(
      firstName: '',
      lastName: '',
      studentCode: '',
      nationalId: '',
      imageUrl: null,
    );
  }

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      firstName: json['first_name'] ?? 'مريم',
      lastName: json['last_name'] ?? 'خليل',
      studentCode: json['student_code'] ?? '808945229',
      nationalId: json['national_id'] ?? '00000000000000',
      imageUrl: json['image'],
    );
  }
}
