import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

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

  Future<HTTPResponseModel> getSignleParentDashboard(String parentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/parents/$parentId/dashboard",
    );
  }
}
