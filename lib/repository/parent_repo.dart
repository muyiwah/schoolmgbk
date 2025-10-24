import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/constants.dart';

class ParentRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> getAllParents() async {
    return await _httpService.runApi(type: ApiRequestType.get, url: "/parents");
  }

  Future<HTTPResponseModel> getSingleParentDetails(String parentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/parents/$parentId",
    );
  }

  Future<HTTPResponseModel> getParentDashboard(String parentId) async {
    print('🔍 DEBUG: ===== PARENT REPO - GET PARENT DASHBOARD =====');
    print('🔍 DEBUG: Parent ID: $parentId');
    print('🔍 DEBUG: Full URL: ${AppConstants.kBaseUrl}/parents/$parentId');
    print('🔍 DEBUG: Method: GET');
    print(
      '🔍 DEBUG: This endpoint provides payment information for parent dashboard',
    );

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/parents/$parentId",
    );
  }

  Future<HTTPResponseModel> updateParent(
    String parentId,
    Map<String, dynamic> updateData,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/parents/$parentId",
      body: updateData,
    );
  }
}
