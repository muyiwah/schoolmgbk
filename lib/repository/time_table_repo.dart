import 'package:flutter/foundation.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/timetable_model.dart';

class TimeTableRepo {
  final _httpService = locator<HttpService>();

  // Create new timetable
  Future<HTTPResponseModel> createTimetable(
    CreateTimetableRequest request,
  ) async {
    try {
      return await _httpService.runApi(
        type: ApiRequestType.post,
        url: "/timetables",
        body: request.toJson(),
      );
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to create timetable: ${e.toString()}',
      }, 500);
    }
  }

  // Get all timetables with filtering
  Future<HTTPResponseModel> getTimetables({
    int page = 1,
    int limit = 10,
    String? classId,
    String? academicYear,
    String? term,
    String? type,
    bool? isActive,
    String sortBy = "createdAt",
    String sortOrder = "desc",
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (classId != null) queryParams['class'] = classId;
      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (term != null) queryParams['term'] = term;
      if (type != null) queryParams['type'] = type;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      return await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/timetables?$queryString",
      );
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get timetables: ${e.toString()}',
      }, 500);
    }
  }

  // Get single timetable details
  Future<HTTPResponseModel> getTimetableDetails(String timetableId) async {
    try {
      return await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/timetables/$timetableId",
      );
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get timetable details: ${e.toString()}',
      }, 500);
    }
  }

  // Update timetable
  Future<HTTPResponseModel> updateTimetable(
    String timetableId,
    UpdateTimetableRequest request,
  ) async {
    try {
      final requestBody = request.toJson();
      if (kDebugMode) {
        print('Update timetable request body: $requestBody');
      }

      final response = await _httpService.runApi(
        type: ApiRequestType.put,
        url: "/timetables/$timetableId",
        body: requestBody,
      );

      if (kDebugMode) {
        print('Update timetable response: ${response.data}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Update timetable error: $e');
      }
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to update timetable: ${e.toString()}',
      }, 500);
    }
  }

  // Delete timetable
  Future<HTTPResponseModel> deleteTimetable(String timetableId) async {
    try {
      return await _httpService.runApi(
        type: ApiRequestType.delete,
        url: "/timetables/$timetableId",
      );
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to delete timetable: ${e.toString()}',
      }, 500);
    }
  }

  // Get class timetable
  Future<HTTPResponseModel> getClassTimetable({
    required String classId,
    String? academicYear,
    String? term,
    String type = "regular",
  }) async {
    try {
      final queryParams = <String, String>{'type': type};

      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (term != null) queryParams['term'] = term;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/timetables/class/$classId?$queryString",
      );

      if (kDebugMode) {
        print('getClassTimetable response: ${response.data}');
      }

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get class timetable: ${e.toString()}',
      }, 500);
    }
  }

  // Legacy methods for backward compatibility
  @Deprecated('Use createTimetable instead')
  Future<HTTPResponseModel> createClassTimeTable(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/timetables",
      body: body,
    );
  }

  @Deprecated('Use getTimetables instead')
  Future<HTTPResponseModel> getAllClassesTimeTable(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables",
      body: body,
    );
  }

  @Deprecated('Use getTimetableDetails instead')
  Future<HTTPResponseModel> getDetailsOfSingeTimeTable(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables/$classId",
    );
  }

  @Deprecated('Use getClassTimetable instead')
  Future<HTTPResponseModel> getClassTimeTable(String classId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables/$classId",
    );
  }

  @Deprecated('Use updateTimetable instead')
  Future<HTTPResponseModel> updateClassTimeTble(
    String classId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/timetables/$classId",
      body: body,
    );
  }
}
