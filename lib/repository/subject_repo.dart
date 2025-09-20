import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class SubjectRepo {
  final _httpService = locator<HttpService>();

  // ✅ Get all subjects
  Future<HTTPResponseModel> getAllSubjects(
    Map<String, dynamic> queryParams,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/subjects",
      params: queryParams,
    );
  }

  // ✅ Get single subject by ID
  Future<HTTPResponseModel> getSingleSubject(String subjectId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/subjects/$subjectId",
    );
  }

  // ✅ Create new subject
  Future<HTTPResponseModel> createSubject(Map<String, dynamic> body) async {


    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/subjects",
      body: body,
    );
  }

  // ✅ Update subject
  Future<HTTPResponseModel> updateSubject(
    String subjectId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/subjects/$subjectId",
      body: body,
    );
  }

  // ✅ Delete subject
  Future<HTTPResponseModel> deleteSubject(String subjectId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/subjects/$subjectId",
    );
  }
}
