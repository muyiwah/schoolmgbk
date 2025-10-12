import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class ClassRepo {
  final _httpService = locator<HttpService>();
  // ✅ Get all classes
  Future<HTTPResponseModel> getAllClasses() async {
    return await _httpService.runApi(type: ApiRequestType.get, url: "/classes");
  }

  // ✅ Get all classes
  Future<HTTPResponseModel> getAllClassesWithMetrics() async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/metrics",
    );
  }

  // ✅ Get all classes
  Future<HTTPResponseModel> getSingleClass(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/$classId",
    );
  }

  // ✅ Get all classes
  Future<HTTPResponseModel> createClass(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes",
      body: body,
    );
  }

  // ✅ Assign subject teacher to class
  Future<HTTPResponseModel> getSubjectTeachers(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/$classId/subject-teachers",
      body: body,
    );
  }

  // ✅ Get fee structures for a class
  Future<HTTPResponseModel> getClassFeeStructure(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/$classId/fee-structures",
    );
  }

  // ✅ add fee structure to a class
  Future<HTTPResponseModel> addFeeStructureToClass(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/$classId/fee-structures",
      body: body,
    );
  }

  // ✅ Update fee structure
  Future<HTTPResponseModel> updateFeeStructure(
    String feeStructureId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/classes/update/$feeStructureId",
      body: body,
    );
  }

  // ✅ Delete fee structure
  Future<HTTPResponseModel> deleteFeeStructure(String feeStructureId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/classes/fee-structures/$feeStructureId",
    );
  }

  // ✅ Set active fee structure for a class
  Future<HTTPResponseModel> setActiveFeeStructure(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/classes/$classId/active-fee-structure",
      body: body,
    );
  }

  // ✅ Update a class fee structure
  Future<HTTPResponseModel> updateClass(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type:
          ApiRequestType
              .put, // or ApiRequestType.patch if that's what your backend expects
      url: "/classes/$classId",
      body: body,
    );
  }

  // ✅ Add curriculum to class
  Future<HTTPResponseModel> addCurriculum(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/classes/$classId/curriculum",
      body: body,
    );
  }

  // ✅ Delete curriculum from class
  Future<HTTPResponseModel> deleteCurriculum(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/classes/$classId/curriculum",
    );
  }

  // ✅ Assign or update class teacher
  Future<HTTPResponseModel> assignClassTeacherToClass(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/$classId/class-teacher",
      body: body,
    );
  }

  // ✅ Get all students in a class
  Future<HTTPResponseModel> getClassStudents(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/$classId/students",
    );
  }

  // ✅ Assign student to class
  Future<HTTPResponseModel> assignStudentToClass(
    String classId,
    String studentId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/$classId/students/$studentId",
      body: body,
    );
  }

  // ✅ Remove teacher from class
  Future<HTTPResponseModel> removeTeacherFromClass(
    String classId,
    String teacherId,
    String role,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/classes/$classId/teachers/$teacherId?role=$role",
      params: {'role': role},
    );
  }

  // ✅ Bulk assign subjects to classes
  Future<HTTPResponseModel> bulkAssignSubjects(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/bulk-assign-subjects",
      body: body,
    );
  }

  // ✅ Get all students with fees (with filters and search)
  Future<HTTPResponseModel> getStudentsWithFees({
    String? search,
    String? searchBy,
    String? classId,
    String? feeStatus,
    String? term,
    String? academicYear,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 50,
  }) async {
    Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
      if (searchBy != null && searchBy.isNotEmpty) {
        queryParams['searchBy'] = searchBy;
      }
    }
    if (classId != null && classId.isNotEmpty) {
      queryParams['classId'] = classId;
    }
    if (feeStatus != null && feeStatus.isNotEmpty) {
      queryParams['feeStatus'] = feeStatus;
    }
    if (term != null && term.isNotEmpty) {
      queryParams['term'] = term;
    }
    if (academicYear != null && academicYear.isNotEmpty) {
      queryParams['academicYear'] = academicYear;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sortOrder'] = sortOrder;
    }

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/students-with-fees",
      params: queryParams,
    );
  }

  // ✅ Get class statistics
  Future<HTTPResponseModel> getClassStatistics({
    String? term,
    String? academicYear,
  }) async {
    Map<String, dynamic> queryParams = {};

    if (term != null && term.isNotEmpty) {
      queryParams['term'] = term;
    }
    if (academicYear != null && academicYear.isNotEmpty) {
      queryParams['academicYear'] = academicYear;
    }

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/statistics",
      params: queryParams,
    );
  }

  // ✅ Get all classes statistics grouped by terms
  Future<HTTPResponseModel> getAllTermsClassStatistics() async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/statistics/all-terms",
    );
  }

  // ✅ Delete class level
  Future<HTTPResponseModel> deleteClassLevel(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/classes/$classId",
    );
  }

  // ✅ Get ImageKit authentication parameters for secure frontend uploads
  Future<HTTPResponseModel> getImageKitAuth() async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/imagekit-auth",
    );
  }
}
