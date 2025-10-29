import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/attendance_model.dart';

class AttendanceRepo {
  final _httpService = locator<HttpService>();

  // Mark attendance for a class
  Future<HTTPResponseModel> markAttendance({
    required String classId,
    required MarkAttendanceRequest request,
  }) async {
    try {
      // print(request.toJson());
      final response = await _httpService.runApi(
        type: ApiRequestType.post,
        url: "/attendance/class/$classId",
        body: request.toJson(),
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to mark attendance: ${e.toString()}',
      }, 500);
    }
  }

  // Get attendance by date for a class
  Future<HTTPResponseModel> getAttendanceByDate({
    required String classId,
    required String date,
  }) async {
    print('Getting attendance by date for class $classId and date $date');
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/attendance/class/$classId/date/$date",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get attendance by date: ${e.toString()}',
      }, 500);
    }
  }

  // Get attendance summary for a class
  Future<HTTPResponseModel> getClassAttendanceSummary({
    required String classId,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/attendance/class/$classId/summary",
      );
   
      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get attendance summary: ${e.toString()}',
      }, 500);
    }
  }

  // Get attendance records for a date range
  Future<HTTPResponseModel> getAttendanceByDateRange({
    required String classId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final queryParams = {'startDate': startDate, 'endDate': endDate};

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/attendance/class/$classId/range?$queryString",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get attendance by date range: ${e.toString()}',
      }, 500);
    }
  }

  // Update attendance record
  Future<HTTPResponseModel> updateAttendanceRecord({
    required String classId,
    required String date,
    required String studentId,
    required String status,
    required String remarks,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.put,
        url: "/attendance/class/$classId/date/$date/student/$studentId",
        body: {'status': status, 'remarks': remarks},
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to update attendance record: ${e.toString()}',
      }, 500);
    }
  }

  // Submit attendance (lock it)
  Future<HTTPResponseModel> submitAttendance({
    required String classId,
    required String date,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.post,
        url: "/attendance/class/$classId/date/$date/submit",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to submit attendance: ${e.toString()}',
      }, 500);
    }
  }
}
