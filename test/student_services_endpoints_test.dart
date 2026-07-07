import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/core/network/api_service.dart';
import 'package:rafiq/features/student_services/data/datasource/student_services_remote_datasource.dart';
import 'package:rafiq/features/student_services/repository/student_services_repository.dart';
import 'package:rafiq/features/student_services/presentation/cubit/student_services_cubit.dart';

// Mock ApiService
class MockApiService extends ApiService {
  MockApiService() : super(baseUrl: 'http://test.com');

  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> post(String path, {dynamic body, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    lastPath = path;
    lastBody = body;
    return {"status": "success"};
  }
  
  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return {"status": "success"};
  }
}

void main() {
  test('Verify Endpoint Routing', () async {
    final mockApi = MockApiService();
    final dataSource = StudentServicesRemoteDataSource(mockApi);
    final repository = StudentServicesRepository(dataSource);
    final cubit = StudentServicesCubit(repository);

    // 1. Academic Appointment
    await cubit.bookService(
      serviceType: 1,
      appointmentDate: DateTime.now(),
      time: "10:00",
      notes: "Test Notes",
    );
    expect(mockApi.lastPath, '/v1/api/students/academic-service/book');
    expect(mockApi.lastBody?['serviceType'], 1);

    // 2. Guidance Request
    await cubit.sendGuidanceRequest(
      studentId: "123",
      title: "Test Title",
      description: "Test Desc",
    );
    expect(mockApi.lastPath, '/v1/api/students/guidance-request/send');

    // 3. Document Request
    await cubit.requestDocument(
      studentId: "123",
      documentType: "طلب إثبات قيد",
      remarks: "Test Remarks",
      topic: "Test Topic",
    );
    expect(mockApi.lastPath, '/v1/api/document-requests');
    expect(mockApi.lastBody?['documentType'], "طلب إثبات قيد");

    print("All endpoints verified successfully!");
  });
}
