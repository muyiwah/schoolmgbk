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
  Future<HTTPResponseModel> addFeeStructureToClass(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/$classId/fee-structures",
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
      url: "/classes/update/$classId",
      body: body,
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
}
