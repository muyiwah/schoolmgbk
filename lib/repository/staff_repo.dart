import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/enums.dart';

class StaffRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> createStaff(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/staff",
      body: body,
    );
  }

  Future<HTTPResponseModel> getAllStaff(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/staff",
      body: body,
    );
  }
}
