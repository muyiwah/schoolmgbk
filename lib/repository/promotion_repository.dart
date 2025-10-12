import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class PromotionRepository {
  final _httpService = locator<HttpService>();

  /// Get promotion eligible students for a class
  Future<HTTPResponseModel> getPromotionEligibleStudents({
    required String classId,
    String? academicYear,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (academicYear != null && academicYear.isNotEmpty) {
      queryParams['academicYear'] = academicYear;
    }

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/promotions/eligible/$classId",
      params: queryParams,
    );
  }

  /// Promote students (bulk or selective)
  Future<HTTPResponseModel> promoteStudents({
    required String fromClassId,
    String? toClassId,
    required String academicYear,
    String? processedBy,
    List<String>? studentIds,
    String promotionType = 'promoted',
    String term = 'First Term',
  }) async {
    final Map<String, dynamic> body = {
      'fromClassId': fromClassId,
      'academicYear': academicYear,
      'promotionType': promotionType,
      'term': term,
    };

    if (toClassId != null && toClassId.isNotEmpty) {
      body['toClassId'] = toClassId;
    }
    if (processedBy != null && processedBy.isNotEmpty) {
      body['processedBy'] = processedBy;
    }
    if (studentIds != null && studentIds.isNotEmpty) {
      body['studentIds'] = studentIds;
    }

    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/promotions/bulk",
      body: body,
    );
  }

  /// Promote individual student
  Future<HTTPResponseModel> promoteIndividualStudent({
    required String studentId,
    String? toClassId,
    required String academicYear,
    String promotionType = 'promoted',
    String? remarks,
  }) async {
    final Map<String, dynamic> body = {
      'studentId': studentId,
      'academicYear': academicYear,
      'promotionType': promotionType,
    };

    if (toClassId != null && toClassId.isNotEmpty) {
      body['toClassId'] = toClassId;
    }
    if (remarks != null && remarks.isNotEmpty) {
      body['remarks'] = remarks;
    }

    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/promotions/individual",
      body: body,
    );
  }

  /// Get promotion history
  Future<HTTPResponseModel> getPromotionHistory({
    int page = 1,
    int limit = 10,
    String? academicYear,
    String sortBy = 'promotionDate',
    String sortOrder = 'desc',
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (academicYear != null && academicYear.isNotEmpty) {
      queryParams['academicYear'] = academicYear;
    }

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/promotions/history",
      params: queryParams,
    );
  }
}
