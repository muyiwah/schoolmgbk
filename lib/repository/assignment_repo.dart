import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class AssignmentRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> getSearchAssignmenets(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/assignments",
      body: body,
    );
  }
  Future<HTTPResponseModel> getSingleAssignmentDetails(String assignmentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/assignments/$assignmentId",
    );
  }
  Future<HTTPResponseModel> createAssignment(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/assignments",
      body: body,
    );
  }
  Future<HTTPResponseModel> stdentSubmitAssignmnet(Map<String, dynamic> body,String assignmentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/assignments/$assignmentId/submit",
      body: body,
    );
  }
  Future<HTTPResponseModel> gradeAssignmnet(Map<String, dynamic> body,String assignmentId,String studentId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/assignments/$assignmentId/grade/$studentId",
      body: body,
    );
  }
  Future<HTTPResponseModel> getSingleStudentAssignment(Map<String, dynamic> body,String assignmentId,String studentId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/assignments/student/$studentId",
      body: body,
    );
  }
}
