class AcademicServiceInitialDataModel {
  final String studentName;
  final String universityCode;
  final String departmentName;
  final String advisorName;
  final String advisorLocation;

  const AcademicServiceInitialDataModel({
    required this.studentName,
    required this.universityCode,
    required this.departmentName,
    required this.advisorName,
    required this.advisorLocation,
  });

  factory AcademicServiceInitialDataModel.fromJson(Map<String, dynamic> json) {
    return AcademicServiceInitialDataModel(
      studentName: (json['studentName'] ?? json['StudentName'] ?? '').toString(),
      universityCode: (json['universityCode'] ?? json['UniversityCode'] ?? '').toString(),
      departmentName: (json['departmentName'] ?? json['DepartmentName'] ?? '').toString(),
      advisorName: (json['advisorName'] ?? json['AdvisorName'] ?? '').toString(),
      advisorLocation: (json['advisorLocation'] ?? json['AdvisorLocation'] ?? '').toString(),
    );
  }
}
