import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class AttendanceRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> markClassAttendance(
    Map<String, dynamic> body,String classId
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/attendance/class/$classId",
      body: body,
    );
  }
  Future<HTTPResponseModel> getClassAssignmentByDate(
    Map<String, dynamic> body,String classId,String date
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/attendance/class/$classId/date/$date",
      body: body,
    );
  }
  Future<HTTPResponseModel> getClassAssignmentSummary(
    Map<String, dynamic> body,String classId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/attendance/class/$classId/summary",
      body: body,
    );
  }
  Future<HTTPResponseModel> getSingleStudentAttendance(
     studentId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/attendance/student/$studentId",
    );
  }
}
