import 'package:schmgtsystem/models/admission_model.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/enums.dart';

class AdmissionRepo {
  static const String _baseUrl = '/admissions';

  // Submit admission intent
  static Future<HTTPResponseModel> submitAdmissionIntent(
    AdmissionSubmissionModel submission,
  ) async {
    try {
      final httpService = HttpService();
      final response = await httpService.runApi(
        type: ApiRequestType.post,
        url: '$_baseUrl/submit',
        body: submission.toJson(),
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to submit admission: $e',
      }, 500);
    }
  }

  // Get all admission intents with filtering and pagination
  static Future<HTTPResponseModel> getAllAdmissionIntents({
    String? status,
    String? academicYear,
    String? desiredClass,
    int page = 1,
    int limit = 10,
    String sortBy = 'submittedAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (status != null) queryParams['status'] = status;
      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (desiredClass != null) queryParams['desiredClass'] = desiredClass;

      final httpService = HttpService();
      print('queryParams: $queryParams');
      final response = await httpService.runApi(
        type: ApiRequestType.get,
        url: _baseUrl,
        params: queryParams,
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch admissions: $e',
      }, 500);
    }
  }

  // Get single admission intent
  static Future<HTTPResponseModel> getAdmissionIntent(String id) async {
    try {
      final httpService = HttpService();
      final response = await httpService.runApi(
        type: ApiRequestType.get,
        url: '$_baseUrl/$id',
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch admission: $e',
      }, 500);
    }
  }

  // Update admission status
  static Future<HTTPResponseModel> updateAdmissionStatus(
    String userId,
    String id,
    String status, {
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    try {
      final data = <String, dynamic>{'status': status};
      data['userId'] = userId;
      if (reviewNotes != null) data['reviewNotes'] = reviewNotes;
      if (rejectionReason != null) data['rejectionReason'] = rejectionReason;

      final httpService = HttpService();
      final response = await httpService.runApi(
        type: ApiRequestType.put,
        url: '$_baseUrl/$id/status',
        body: data,
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to update admission status: $e',
      }, 500);
    }
  }

  // Admit student (create student from admission)
  static Future<HTTPResponseModel> admitStudent(
    String userId,
    String id, {
    Map<String, dynamic>? additionalStudentData,
  }) async {
    try {
      final data = <String, dynamic>{};
      data['userId'] = userId;
      if (additionalStudentData != null) {
        data['additionalStudentData'] = additionalStudentData;
      }

      final httpService = HttpService();
      final response = await httpService.runApi(
        type: ApiRequestType.post,
        url: '$_baseUrl/$id/admit',
        body: data,
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to admit student: $e',
      }, 500);
    }
  }

  // Get admission statistics
  static Future<HTTPResponseModel> getAdmissionStatistics({
    String? academicYear,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (academicYear != null) queryParams['academicYear'] = academicYear;

      final httpService = HttpService();
      final response = await httpService.runApi(
        type: ApiRequestType.get,
        url: '$_baseUrl/statistics',
        params: queryParams,
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch admission statistics: $e',
      }, 500);
    }
  }
}
