import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/class_level_model.dart';

class ClassLevelRepo {
  final _httpService = locator<HttpService>();

  // Get all class levels
  Future<HTTPResponseModel> getAllClassLevels({
    String? category,
    bool? isActive,
  }) async {
    Map<String, dynamic> queryParams = {};

    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/levels",
      params: queryParams,
    );
  }

  // Get single class level by ID
  Future<HTTPResponseModel> getClassLevel(String id) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/classes/levels/$id",
    );
  }

  // Create new class level
  Future<HTTPResponseModel> createClassLevel(Map<String, dynamic> data) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/levels",
      body: data,
    );
  }

  // Update class level
  Future<HTTPResponseModel> updateClassLevel(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/classes/levels/$id",
      body: data,
    );
  }

  // Delete class level
  Future<HTTPResponseModel> deleteClassLevel(String id) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/classes/levels/$id",
    );
  }

  // Reorder class levels
  Future<HTTPResponseModel> reorderClassLevels(
    ReorderClassLevelsModel reorderData,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/classes/levels/reorder",
      body: reorderData.toJson(),
    );
  }

  // Bulk create class levels
  Future<HTTPResponseModel> bulkCreateClassLevels(
    BulkCreateClassLevelsModel bulkData,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/classes/levels/bulk-create",
      body: bulkData.toJson(),
    );
  }
}
