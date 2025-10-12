import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class StudentsRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> getAllStudents({
    int page = 1,
    int limit = 10,
    String? classId,
    String? gender,
    String? feeStatus,
    String? status,
    String? academicYear,
    String? search,
    String sortBy = "personalInfo.firstName",
    String sortOrder = "asc",
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    // Add optional parameters only if they are provided
    if (classId != null && classId.isNotEmpty) queryParams['class'] = classId;
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
    if (feeStatus != null && feeStatus.isNotEmpty)
      queryParams['feeStatus'] = feeStatus;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (academicYear != null && academicYear.isNotEmpty)
      queryParams['academicYear'] = academicYear;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    // Debug logging
    print('🔍 StudentsRepo: Query parameters: $queryParams');
    print('🔍 StudentsRepo: Gender filter: $gender');
    print('🔍 StudentsRepo: FeeStatus filter: $feeStatus');
    print('🔍 StudentsRepo: ClassId filter: $classId');

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/students",
      params: queryParams,
    );
  }

  Future<HTTPResponseModel> createStudent(Map<String, dynamic> body) async {
    print('🔍 StudentsRepo: Creating student: $body');
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/students",
      body: body,
    );
  }

  Future<HTTPResponseModel> assignStudentToClass(
    // body takes "classId": "68a386c5fc888b6066cff7e0"
    String studentId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/students/$studentId/assign-class", // <-- studentId goes here
      body: body,
    );
  }

  Future<HTTPResponseModel> getStudentById(String studentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/students/$studentId",
    );
  }

  Future<HTTPResponseModel> updateStudent(
    //eample {"personalInfo.lastName": "Tolani", }
    String studentId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put, // or patch, depending on your backend
      url: "/students/$studentId",
      body: body,
    );
  }

  Future<HTTPResponseModel> deleteStudent(String studentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/students/$studentId",
    );
  }
}
